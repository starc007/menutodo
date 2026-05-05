import XCTest
@testable import menutodo

final class TodoStoreTests: XCTestCase {
    var store: TodoStore!
    var tempURL: URL!

    override func setUp() {
        super.setUp()
        tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString + ".json")
        store = TodoStore(fileURL: tempURL)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tempURL)
        super.tearDown()
    }

    func testAdd_appendsItem() {
        store.add("test todo")
        XCTAssertEqual(store.todos.count, 1)
        XCTAssertEqual(store.todos[0].text, "test todo")
        XCTAssertFalse(store.todos[0].done)
    }

    func testAdd_trimsWhitespace() {
        store.add("  spaced  ")
        XCTAssertEqual(store.todos[0].text, "  spaced  ")
    }

    func testToggle_flipsState() {
        store.add("test")
        let item = store.todos[0]
        store.toggle(item)
        XCTAssertTrue(store.todos[0].done)
        store.toggle(store.todos[0])
        XCTAssertFalse(store.todos[0].done)
    }

    func testDelete_removesCorrectItem() {
        store.add("keep")
        store.add("remove")
        let toDelete = store.todos[1]
        store.delete(toDelete)
        XCTAssertEqual(store.todos.count, 1)
        XCTAssertEqual(store.todos[0].text, "keep")
    }

    func testClearCompleted_keepsPending() {
        store.add("pending")
        store.add("done item")
        store.toggle(store.todos[1])
        store.clearCompleted()
        XCTAssertEqual(store.todos.count, 1)
        XCTAssertEqual(store.todos[0].text, "pending")
    }

    func testPendingCount_excludesDone() {
        store.add("a")
        store.add("b")
        store.add("c")
        store.toggle(store.todos[0])
        XCTAssertEqual(store.pendingCount, 2)
    }

    func testPersistence_savesAndLoadsAcrossInstances() {
        store.add("persistent todo")
        store.toggle(store.todos[0])

        let store2 = TodoStore(fileURL: tempURL)
        XCTAssertEqual(store2.todos.count, 1)
        XCTAssertEqual(store2.todos[0].text, "persistent todo")
        XCTAssertTrue(store2.todos[0].done)
    }

    func testPersistence_emptyFileReturnsEmptyList() {
        let store2 = TodoStore(fileURL: tempURL)
        XCTAssertEqual(store2.todos.count, 0)
    }
}
