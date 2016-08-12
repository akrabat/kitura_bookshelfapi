import CouchDB
import Foundation
import LoggerAPI
import SwiftyJSON

class BooksMapper {
    let database: Database;

    init(withDatabase db: Database) {
        self.database = db
    }

    ///
    /// Fetch all books using the books/all view
    ///
    func fetchAll() -> [Book]? {
        var books: [Book]?

        database.queryByView("all_books", ofDesign: "main_design", usingParameters: []) {
            (document: JSON?, error: NSError?) in
            if let document = document, error == nil {
                // create an array of Books from document
                if let list = document["rows"].array {
                    books = list.map {
                        let data = $0["value"];
                        let bookId = data["_id"].stringValue + ":" + data["_rev"].stringValue

                        return Book(id: bookId, title: data["title"].stringValue,
                            author: data["author"].stringValue, isbn: data["isbn"].stringValue)
                    }
                }
            } else {
                Log.error("Something went wrong; could not fetch all books.")
                if let error = error {
                    Log.error("CouchDB error: \(error.localizedDescription). Code: \(error.code)")
                }
            }
        }

        return books
    }
}
