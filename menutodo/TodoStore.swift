import Foundation
import Observation

@Observable
final class TodoStore {
    private(set) var todos: [TodoItem] = []
    private let fileURL: URL

    init(fileURL: URL = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".menutodo.json")) {
        self.fileURL = fileURL
        load()
    }

    var pendingCount: Int {
        todos.filter { !$0.done }.count
    }

    func add(_ text: String) {
        todos.append(TodoItem(text: text))
        save()
    }

    func toggle(_ item: TodoItem) {
        guard let index = todos.firstIndex(where: { $0.id == item.id }) else { return }
        todos[index].done.toggle()
        save()
    }

    func delete(_ item: TodoItem) {
        todos.removeAll { $0.id == item.id }
        save()
    }

    func clearCompleted() {
        todos.removeAll { $0.done }
        save()
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let decoded = try? decoder.decode([TodoItem].self, from: data) {
            todos = decoded
        }
    }

    private func save() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        do {
            let data = try encoder.encode(todos)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("[menutodo] Failed to save todos: \(error)")
        }
    }
}
