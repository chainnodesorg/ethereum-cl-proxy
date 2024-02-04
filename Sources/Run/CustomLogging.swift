import Foundation
import Logging
import Vapor

private class CustomLoggingDateFormatter {
    private static var internalInstance: CustomLoggingDateFormatter?

    static var instance: CustomLoggingDateFormatter {
        if let internalInstance {
            return internalInstance
        }

        let initialized = CustomLoggingDateFormatter()
        internalInstance = initialized

        return initialized
    }

    let formatter: DateFormatter

    private init() {
        formatter = DateFormatter()
        formatter.dateFormat = "[dd-MM-yy|HH:mm:ss.SSS]"
    }
}

/// Outputs logs to a `Console` with date.
private struct CustomConsoleLogger: LogHandler {
    let label: String

    /// See `LogHandler.metadata`.
    var metadata: Logger.Metadata

    /// See `LogHandler.metadataProvider`.
    var metadataProvider: Logger.MetadataProvider?

    /// See `LogHandler.logLevel`.
    var logLevel: Logger.Level

    /// The conosle that the messages will get logged to.
    let console: Console

    /// Creates a new `ConsoleLogger` instance.
    ///
    /// - Parameters:
    ///   - label: Unique identifier for this logger.
    ///   - console: The console to log the messages to.
    ///   - level: The minimum level of message that the logger will output. This defaults to `.debug`, the lowest
    /// level.
    ///   - metadata: Extra metadata to log with the message. This defaults to an empty dictionary.
    init(label: String, console: Console, level: Logger.Level = .debug, metadata: Logger.Metadata = [:]) {
        self.label = label
        self.metadata = metadata
        logLevel = level
        self.console = console
    }

    init(
        label: String,
        console: Console,
        level: Logger.Level = .debug,
        metadata: Logger.Metadata = [:],
        metadataProvider: Logger.MetadataProvider?
    ) {
        self.label = label
        self.metadata = metadata
        logLevel = level
        self.console = console
        self.metadataProvider = metadataProvider
    }

    /// See `LogHandler[metadataKey:]`.
    ///
    /// This just acts as a getter/setter for the `.metadata` property.
    subscript(metadataKey key: String) -> Logger.Metadata.Value? {
        get { metadata[key] }
        set { metadata[key] = newValue }
    }

    private static let logLevelMaxCharacters = Logger.Level.allCases.reduce(0) { old, level in
        let levelCount = "\(level.name)".count
        if old < levelCount {
            return levelCount
        }

        return old
    }

    /// See `LogHandler.log(level:message:metadata:file:function:line:)`.
    func log(
        level: Logger.Level,
        message: Logger.Message,
        metadata: Logger.Metadata?,
        file: String,
        function _: String,
        line: UInt
    ) {
        var text: ConsoleText = ""

        if logLevel <= .trace {
            text += "[\(label)] ".consoleText()
        }

        let difference = CustomConsoleLogger.logLevelMaxCharacters - "\(level.name)".count
        let leftDifference = difference / 2
        let rightDifference = difference % 2 == 0 ? leftDifference : leftDifference + 1
        text +=
            "[\(String(repeating: " ", count: leftDifference))\(level.name)\(String(repeating: " ", count: rightDifference))] "
            .consoleText(level.style)

        text += "\(CustomLoggingDateFormatter.instance.formatter.string(from: Date())) "

        text += message.description.consoleText()

        let allMetadata = (metadata ?? [:])
            .merging(self.metadata, uniquingKeysWith: { a, _ in a })
            .merging(metadataProvider?.get() ?? [:], uniquingKeysWith: { a, _ in a })

        if !allMetadata.isEmpty {
            // only log metadata if not empty
            text += " " + allMetadata.sortedDescriptionWithoutQuotes.consoleText()
        }

        // log file info if we are debug or lower
        if logLevel <= .debug {
            // log the concise path + line
            let fileInfo = conciseSourcePath(file) + ":" + line.description
            text += " (" + fileInfo.consoleText() + ")"
        }

        console.output(text)
    }

    /// splits a path on the /Sources/ folder, returning everything after
    ///
    ///     "/Users/developer/dev/MyApp/Sources/Run/main.swift"
    ///     // becomes
    ///     "Run/main.swift"
    ///
    private func conciseSourcePath(_ path: String) -> String {
        let separator: Substring = path.contains("Sources") ? "Sources" : "Tests"
        return path.split(separator: "/")
            .split(separator: separator)
            .last?
            .joined(separator: "/") ?? path
    }
}

private extension Logger.Metadata {
    var sortedDescriptionWithoutQuotes: String {
        let contents = Array(self)
            .sorted(by: { $0.0 < $1.0 })
            .map { "\($0.description): \($1)" }
            .joined(separator: ", ")
        return "[\(contents)]"
    }
}

public extension LoggingSystem {
    static func bootstrapCustom(
        from environment: inout Environment,
        _ factory: (Logger.Level) -> (String) -> LogHandler
    ) throws {
        let level = try Logger.Level.detect(from: &environment)

        // Disable stack traces if log level > trace.
        if level > .trace {
            StackTrace.isCaptureEnabled = false
        }

        // Bootstrap logger with a factory created by the factoryfactory.
        return LoggingSystem.bootstrap(factory(level))
    }

    static func bootstrapCustom(from environment: inout Environment) throws {
        try bootstrapCustom(from: &environment) { level in
            let console = Terminal()
            return { (label: String) in
                CustomConsoleLogger(
                    label: label,
                    console: console,
                    level: level
                )
            }
        }
    }
}
