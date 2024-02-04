import Vapor

func routes(_ app: Application) throws {
    // Metrics
    try app.register(collection: MetricsController(app: app))
    // Health
    try app.register(collection: HealthController(app: app))
    // Robots
    try app.register(collection: RobotsController(app: app))
    // Proxy
    try app.register(collection: ProxyController(app: app))
}
