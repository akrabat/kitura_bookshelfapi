import CouchDB
import DotEnv
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
let env = DotEnv()

let connectionProperties = ConnectionProperties(
    host: env.get("DB_HOST") ?? "localhost",
    port: Int16(env.getAsInt("DB_PORT") ?? 5984),
    secured: env.getAsBool("DB_HTTPS") ?? false,
    username: env.get("DB_USERNAME") ?? "rob",
    password: env.get("DB_PASSWORD") ?? "123456"
)
let databaseName = env.get("DB_NAME") ?? "bookshelf_db"

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
router.get("/books/:id", handler: getBookHandler)
router.post("/books", handler: createBookHandler)

// Start server
Log.info("Starting server")
let port = env.getAsInt("APP_PORT") ?? 8090
Kitura.addHTTPServer(onPort: port, with: router)
Kitura.run()
