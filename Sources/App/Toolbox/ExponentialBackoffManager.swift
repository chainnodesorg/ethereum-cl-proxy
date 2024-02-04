import Foundation
import NIO
import NIOConcurrencyHelpers

class ExponentialBackoffManager<Element: Hashable> {
    private let backoffTimings: NIOLockedValueBox<[Element: (backedOffAt: Date, backedOffCount: Int)]> = .init([:])

    private let startBackoffTimeAmount: TimeAmount
    private let maxBackoffTimeAmount: TimeAmount
    private let backoffFactor: Double

    /// Creates a backoff timer that saves backed off items and returns how long to back off if an error happens again.
    ///
    /// - Parameters:
    ///   - startBackoffTimeAmount: The first backoff time amount.
    ///   - maxBackoffTimeAmount: The maximum time amount to back off, basically a cap.
    ///   - backoffFactor: The factor at which to increase the backoff. Required to be >1.
    init(startBackoffTimeAmount: TimeAmount, maxBackoffTimeAmount: TimeAmount, backoffFactor: Double = 1.5) {
        self.startBackoffTimeAmount = startBackoffTimeAmount
        self.maxBackoffTimeAmount = maxBackoffTimeAmount
        self.backoffFactor = backoffFactor
    }

    /// Returns how long to backoff for the given item.
    /// - Parameter element: The element to return backoff for.
    /// - Returns: The time amount to wait. Caps at `maxBackoffTimeAmount`.
    func backoff(element: Element) -> TimeAmount {
        backoffTimings.withLockedValue {
            let backedOffCount: Int = if let currentBackoff = $0[element] {
                currentBackoff.backedOffCount
            } else {
                0
            }

            var nextBackoffTimeNanoseconds = Int64(
                Double(self.startBackoffTimeAmount.nanoseconds) * pow(
                    self.backoffFactor,
                    Double(backedOffCount)
                )
            )
            var nextBackoffCount = backedOffCount + 1

            if nextBackoffTimeNanoseconds > self.maxBackoffTimeAmount.nanoseconds {
                nextBackoffTimeNanoseconds = self.maxBackoffTimeAmount.nanoseconds
                nextBackoffCount = backedOffCount
            }

            $0[element] = (backedOffAt: Date(), backedOffCount: nextBackoffCount)

            return TimeAmount.nanoseconds(nextBackoffTimeNanoseconds)
        }
    }

    /// Resets the backoff for the given element.
    /// - Parameter element: The element to reset the backoff for.
    func resetBackoff(element: Element) {
        backoffTimings.withLockedValue {
            $0[element] = nil
        }
    }
}
