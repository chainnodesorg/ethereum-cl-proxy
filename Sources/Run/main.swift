import App
import Vapor

var env = try Environment.detect()

// Logging
try LoggingSystem.bootstrapCustom(from: &env)

// The App
let app = Application(env)
defer { app.shutdown() }

// Configure and run
try configure(app)
try app.run()
