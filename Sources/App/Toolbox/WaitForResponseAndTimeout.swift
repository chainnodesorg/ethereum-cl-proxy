import Foundation
import NIO
import NIOConcurrencyHelpers

enum WaitForResponseAndTimeout {
    enum Error: Swift.Error {
        case timeoutAfterOtherResponse
        case responseError(originalError: Swift.Error)

        case genericError(originalError: Swift.Error)

        case noResponsesError
    }

    /// Returns the consens of responses according to rational logic.
    ///
    /// - Parameter responses: The responses to check.
    /// - Returns: The response chosen and the number of times it was present in the array.
    static func consensResponses<Response: Hashable>(_ responses: [Response]) throws -> (Response, Int) {
        guard responses.count > 0 else {
            throw Error.noResponsesError
        }

        // Caution: Dictionaries don't like openapi types.
        // The below is O(n^2) but unless upstream fixes the issue
        // that `.jsonResponse` values do not correctly follow Hashable rules,
        // we need to go with this.
        // Plus, even with 11 beacon nodes (max recommended), this is only O(121).

        let responseCounts: [(Response, Int)] = responses.map { element in
            (element, responses.filter { $0 == element }.count)
        }.sorted(by: {
            $0.1 > $1.1
        })

        guard responseCounts.count > 0 else {
            throw Error.noResponsesError
        }

        let bestResponse = responseCounts.first!

        return (bestResponse.0, bestResponse.1)
    }

    static func multiple<Response>(
        _ futures: [() async throws -> Response],
        timeout: TimeAmount
    ) async throws -> [Result<Response, Error>] {
        guard futures.count > 0 else {
            return []
        }

        // Generic lock for finalizations.
        let lock = NIOLock()

        // An atomic lock that saves whether the first response has been received already.
        let firstFinalizedFuture: NIOLockedValueBox<Bool> = .init(true)

        // Cancellations still waiting to be cancelled.
        let waitingCancellations: NIOLockedValueBox<[() -> Void]> = .init(.init(repeating: {}, count: futures.count))

        // Helper for generic timeout cancellable future.
        func wrapFuture(_ future: @escaping () async throws -> Response, index: Int) async throws -> Response {
            let futureResult: Response = try await withCheckedThrowingContinuation { continuation in
                let futureTask = Task {
                    let result: Response
                    do {
                        result = try await future()
                    } catch {
                        // Needs to be in the lock
                        try lock.withLock {
                            // If cancelled, we want to do nothing as this is continued already
                            try Task.checkCancellation()

                            // Prevent future cancellation
                            waitingCancellations.withLockedValue {
                                $0[index] = {}
                            }

                            // Continue if not cancelled yet
                            continuation.resume(throwing: Error.responseError(originalError: error))
                        }
                        return
                    }

                    // Success result
                    try lock.withLock {
                        try Task.checkCancellation()

                        // Prevent future cancellation
                        waitingCancellations.withLockedValue {
                            $0[index] = {}
                        }

                        // If this is the first proper result, we will schedule the timeout now.
                        let isFirst = firstFinalizedFuture.withLockedValue {
                            let previous = $0
                            $0 = false
                            return previous
                        }
                        if isFirst {
                            Task {
                                try await Task.sleep(nanoseconds: UInt64(timeout.nanoseconds))

                                let cancellations = waitingCancellations.withLockedValue {
                                    let previous = $0
                                    $0 = .init(repeating: {}, count: futures.count)
                                    return previous
                                }

                                for cancellation in cancellations {
                                    cancellation()
                                }
                            }
                        }

                        // Return the response
                        continuation.resume(returning: result)
                    }
                }

                waitingCancellations.withLockedValue {
                    $0[index] = {
                        lock.withLock {
                            futureTask.cancel()

                            // Explicitly fail the continuation to resolve early.
                            continuation.resume(throwing: Error.timeoutAfterOtherResponse)
                        }
                    }
                }
            }

            return futureResult
        }

        let finalResponses = try await withThrowingTaskGroup(
            of: Result<Response, Error>.self,
            returning: [Result<Response, Error>].self
        ) { group in
            for i in 0 ..< futures.count {
                group.addTask {
                    let result: Response
                    do {
                        result = try await wrapFuture(futures[i], index: i)
                    } catch let error as Error {
                        return Result.failure(error)
                    } catch {
                        return Result.failure(Error.genericError(originalError: error))
                    }

                    return Result.success(result)
                }
            }

            return try await group.reduce(into: []) { $0.append($1) }
        }

        return finalResponses
    }
}
