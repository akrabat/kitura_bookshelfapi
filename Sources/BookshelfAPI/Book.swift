import SwiftyJSON

struct Book {
    let id: String
    let title: String
    let author: String
    let isbn: String

    init(id: String, title: String, author: String, isbn: String) {
        self.id = id
        self.title = title
        self.author = author
        self.isbn = isbn
    }

    func toJSON() -> JSON {
        return JSON([
            "title": title,
            "author": author,
            "isbn": isbn,
        ])
    }
}
