import Vapor

struct HealthController: RouteCollection {
    private let jsonEncoder = JSONEncoder()

    private let app: Application

    init(app: Application) {
        self.app = app
    }

    func boot(routes: RoutesBuilder) throws {
        routes.get("healthz") { _ in
            let status: HTTPStatus = .ok

            let responseBody = Response.Body(data: Data())
            return Response(
                status: status,
                headers: HTTPHeaders([("Content-Type", "application/json")]),
                body: responseBody
            )
        }
    }
}
