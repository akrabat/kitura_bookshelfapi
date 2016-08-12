import HeliumLogger
import Foundation
import Kitura
import LoggerAPI
import SwiftyJSON

// Disable buffering
setbuf(stdout, nil)

// Attach a logger
Log.logger = HeliumLogger()

// setup routes
let router = Router()
router.get("/") { _, response, next in
    response.status(.OK).send(json: JSON(["hello" : "world"]))
    next()
}

// Start server
Log.info("Starting server")
Kitura.addHTTPServer(onPort: 8090, with: router)
Kitura.run()
