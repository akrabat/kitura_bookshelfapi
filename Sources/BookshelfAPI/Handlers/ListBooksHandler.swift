import CouchDB
import Kitura
import LoggerAPI
import SwiftyJSON

func listBooksHandler(request: RouterRequest, response: RouterResponse, next: ()->Void) -> Void {
    Log.info("Handling /books")
    if let books = booksMapper.fetchAll() {
        var json = JSON([:])

        json["books"] = JSON(books.map { $0.toJSON() })
        json["count"].int = books.count

        response.status(.OK).send(json: json)
    } else {
        response.status(.internalServerError).send(json: JSON(["error": "Could not service request"]))
    }
    next()
}
