import Foundation
import Vapor

struct ProxyController: RouteCollection {
    private let jsonEncoder = JSONEncoder()

    private let app: Application

    init(app: Application) {
        self.app = app
    }

    func boot(routes _: RoutesBuilder) throws {}
}
