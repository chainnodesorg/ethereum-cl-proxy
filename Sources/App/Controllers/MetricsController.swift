import CoreMetrics
import Foundation
import Prometheus
import Vapor

struct MetricsController: RouteCollection {
    let app: Application

    init(app: Application) {
        self.app = app
    }

    func boot(routes: RoutesBuilder) throws {
        routes.on(.GET, "metrics", body: .collect(maxSize: .init(value: 1024 * 1024 * 30))) { _ in
            try await MetricsSystem.prometheus().collect()
        }
    }
}
