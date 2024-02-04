import Vapor

struct RobotsController: RouteCollection {
    private let app: Application

    init(app: Application) {
        self.app = app
    }

    func boot(routes: RoutesBuilder) throws {
        routes.get("robots.txt") { _ in
            let robotsTxtReturn = """
            User-agent: *
            Disallow: /
            """

            let responseBody = Response.Body(data: Data(robotsTxtReturn.utf8))
            return Response(
                status: HTTPStatus.ok,
                headers: HTTPHeaders([("Content-Type", "text/plain")]),
                body: responseBody
            )
        }
    }
}
