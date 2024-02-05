import CoreMetrics
import OpenAPIVapor
import Prometheus
import Vapor
#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // MARK: - Database

    // Migrations

    // app.migrations.add(CreateTodo())

    // MARK: - Prometheus Metrics

    let prometheus = PrometheusClient()
    MetricsSystem.bootstrap(PrometheusMetricsFactory(client: prometheus))

    // MARK: - Services

    app.downstreamBeaconService = try .init(app: app)

    // MARK: - Middlewares

    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .all,
        allowedMethods: [.GET, .HEAD, .POST, .PUT, .DELETE, .CONNECT, .OPTIONS, .TRACE, .PATCH],
        allowedHeaders: ["*"],
        allowCredentials: true
    )
    let cors = CORSMiddleware(configuration: corsConfiguration)
    // cors middleware should come before default error middleware using `at: .beginning`
    app.middleware.use(cors, at: .beginning)

    // MARK: - App Config

    // Bind to 0.0.0.0
    app.http.server.configuration.hostname = "0.0.0.0"
    app.http.server.configuration.port = Environment.get("HTTP_PORT").flatMap(Int.init(_:)) ?? 8080

    // MARK: - Routes

    // register routes
    try routes(app)
}

private extension String {
    func toInt() -> Int? {
        Int(self)
    }
}
