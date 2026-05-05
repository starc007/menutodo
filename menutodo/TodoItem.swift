import Foundation

struct TodoItem: Identifiable, Codable {
    let id: UUID
    var text: String
    var done: Bool
    let created: Date

    init(id: UUID = UUID(), text: String, done: Bool = false, created: Date = Date()) {
        self.id = id
        self.text = text
        self.done = done
        self.created = created
    }
}
