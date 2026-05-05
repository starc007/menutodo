import Foundation

struct TodoItem: Identifiable, Codable {
    let id: UUID
    var text: String
    var done: Bool
    var tag: String?
    let created: Date

    init(id: UUID = UUID(), text: String, done: Bool = false, tag: String? = nil, created: Date = Date()) {
        self.id = id
        self.text = text
        self.done = done
        self.tag = tag
        self.created = created
    }
}
