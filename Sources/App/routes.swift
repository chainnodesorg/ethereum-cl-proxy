import BeaconAPI
import OpenAPIVapor
import Vapor

func routes(_ app: Application) throws {
    // Metrics
    try app.register(collection: MetricsController(app: app))
    // Health
    try app.register(collection: HealthController(app: app))
    // Robots
    try app.register(collection: RobotsController(app: app))
    // Proxy
    let proxyController = ProxyController(app: app)
    try app.register(collection: proxyController)

    // Register OpenAPI BeaconNode routes
    let transport = VaporTransport(routesBuilder: app)
    try proxyController.registerHandlers(on: transport, serverURL: URL(string: "/")!)
}
