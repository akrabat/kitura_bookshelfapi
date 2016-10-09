import CouchDB
import Kitura
import LoggerAPI
import SwiftyJSON

func createBookHandler(request: RouterRequest, response: RouterResponse, next: ()->Void) -> Void {
    Log.info("Handling a post to /books")

    let contentType = request.headers["Content-Type"] ?? "";
    guard let rawData = try! request.readString(),
        contentType.hasPrefix("application/json") else {
        Log.info("No data")
        response.status(.badRequest).send(json: JSON(["error": "No data received"]))
        next()
        return
    }

    let jsonData = JSON.parse(string: rawData)
    do {
        let book = try booksMapper.insertBook(json: jsonData)

        var json = book.toJSON()

        let baseURL = "http://" + (request.headers["Host"] ?? "localhost:8090")
        let links = JSON(["self": baseURL + "/books/" + book.id])
        json["_links"] = links

        response.status(.OK).send(json: json)
        response.headers["Content-Type"] = "application/hal+json"
    } catch BooksMapper.RetrieveError.Invalid(let message) {
        response.status(.badRequest).send(json: JSON(["error": message]))
    } catch {
        response.status(.internalServerError).send(json: JSON(["error": "Could not service request"]))
    }

    next()
}
