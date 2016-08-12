import CouchDB
import Foundation
import HeliumLogger
import Kitura
import LoggerAPI
import SwiftyJSON

// Disable buffering
setbuf(stdout, nil)

// Attach a logger
Log.logger = HeliumLogger()

// Database connection
let connectionProperties = ConnectionProperties(
    host: "localhost",
    port: 5984,
    secured: false,
    username: "rob",
    password: "123456"
)
let databaseName = "bookshelf_db"

let client = CouchDBClient(connectionProperties: connectionProperties)
let database = client.database(databaseName)
let booksMapper = BooksMapper(withDatabase: database)

// setup routes
let router = Router()
router.get("/") { _, response, next in
    response.status(.OK).send(json: JSON(["hello" : "world"]))
    next()
}

router.get("/books", handler: listBooksHandler)

// Start server
Log.info("Starting server")
Kitura.addHTTPServer(onPort: 8090, with: router)
Kitura.run()
