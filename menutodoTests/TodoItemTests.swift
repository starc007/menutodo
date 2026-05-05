import XCTest
@testable import menutodo

final class TodoItemTests: XCTestCase {

    func testInit_defaults() {
        let item = TodoItem(text: "buy milk")
        XCTAssertFalse(item.done)
        XCTAssertEqual(item.text, "buy milk")
        XCTAssertEqual(item.created.timeIntervalSinceNow, 0, accuracy: 1.0)
    }

    func testCodable_roundtrip() throws {
        let id = UUID()
        let date = Date(timeIntervalSince1970: 1000)
        let item = TodoItem(id: id, text: "test task", done: true, created: date)

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(item)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(TodoItem.self, from: data)

        XCTAssertEqual(decoded.id, id)
        XCTAssertEqual(decoded.text, "test task")
        XCTAssertTrue(decoded.done)
        XCTAssertEqual(decoded.created, date)
    }

    func testIdentifiable_uniqueIDs() {
        let a = TodoItem(text: "a")
        let b = TodoItem(text: "b")
        XCTAssertNotEqual(a.id, b.id)
    }
}
