import CouchDB
import Foundation
import LoggerAPI
import SwiftyJSON

class BooksMapper {

    enum RetrieveError: Error {
        case NotFound
        case Invalid(String)
        case Unknown
    }

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

    ///
    /// Fetch a single book using the books/all view
    ///
    func fetchBook(withId id: String) throws -> Book {

        // The id contains both the id and the rev separated by a :, so split
        let parts = id.characters.split { $0 == ":"}.map(String.init)
        let bookId = parts[0]

        var book: Book?
        var error: RetrieveError = RetrieveError.Unknown
        database.retrieve(bookId, callback: { (document: JSON?, err: NSError?) in

            if let document = document {
                let bookId = document["_id"].stringValue + ":" + document["_rev"].stringValue
                book = Book(id: bookId, title: document["title"].stringValue,
                    author: document["author"].stringValue, isbn: document["isbn"].stringValue)
                return
            }

            if let err = err {
                switch err.code {
                    case 404: // not found
                        error = RetrieveError.NotFound
                    default: // some other error
                        Log.error("Oops something went wrong; could not read document.")
                        Log.info("Error: \(err.localizedDescription). Code: \(err.code)")
                }
            }
        })

        if book == nil {
            throw error
        }

        return book!
    }

    ///
    /// Add a book to the database
    ///
    func insertBook(json: JSON) throws -> Book {
        // validate required values
        guard let title = json["title"].string,
            let author = json["author"].string else {
            throw RetrieveError.Invalid("A Book must have a title and an author")
        }
        // optional values
        let isbn = json["isbn"].stringValue

        // create a JSON object to store which contains just the properties we need
        let bookJson = JSON([
            "type": "book",
            "author": author,
            "title": title,
            "isbn": isbn,
        ])

        var book: Book?
        database.create(bookJson) { (id, revision, document, err) in
            if let id = id, let revision = revision, err == nil {
                Log.info("Created book \(title) with id of \(id)")
                let bookId = "\(id):\(revision)"
                book = Book(id: bookId, title: title, author: author, isbn: isbn)
                return
            }

            Log.error("Oops something went wrong; could not create book.")
            if let err = err {
                Log.info("Error: \(err.localizedDescription). Code: \(err.code)")
            }
        }

        if book == nil {
            throw RetrieveError.Unknown
        }

        return book!
    }
}
