import CouchDB
import Kitura
import LoggerAPI
import SwiftyJSON

func getBookHandler(request: RouterRequest, response: RouterResponse, next: ()->Void) -> Void {
    guard let id: String = request.parameters["id"] else {
        response.status(.notFound).send(json: JSON(["error": "Not Found"]))
        next()
        return
    }

    Log.info("Handling /book/\(id)")

    do {
        let book = try booksMapper.fetchBook(withId: id)

        var json = book.toJSON()

        let baseURL = "http://" + (request.headers["Host"] ?? "localhost:8090")
        let links = JSON(["self": baseURL + "/books/" + book.id])
        json["_links"] = links

        response.status(.OK).send(json: json)
    } catch BooksMapper.RetrieveError.NotFound {
        response.status(.notFound).send(json: JSON(["error": "Not found"]))
    } catch {
        response.status(.internalServerError).send(json: JSON(["error": "Could not service request"]))
    }

    next()
}
