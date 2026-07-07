import XCTest
@testable import Vendly

@MainActor
final class VendlyTests: XCTestCase {
    var store: VendlyStore!

    override func setUp() async throws {
        store = VendlyStore()
    }

    func testSeedDataLoaded() {
        XCTAssertFalse(store.entries.isEmpty)
    }

    func testAddIncreasesCount() {
        let before = store.entries.count
        store.add(title: "Test Entry", amount: 5.0)
        XCTAssertEqual(store.entries.count, before + 1)
    }

    func testTotalReflectsAmounts() {
        let entriesBefore = store.total
        store.add(title: "Extra", amount: 3.5)
        XCTAssertEqual(store.total, entriesBefore + 3.5, accuracy: 0.0001)
    }

    func testFreeLimitBlocksAddition() {
        store.isPro = false
        for i in 0..<(VendlyStore.freeLimit + 5) {
            store.add(title: "Filler \(i)", amount: 1.0)
        }
        XCTAssertEqual(store.entries.count, VendlyStore.freeLimit)
    }

    func testCanAddMoreWhenPro() {
        store.isPro = true
        for i in 0..<(VendlyStore.freeLimit + 5) {
            store.add(title: "Filler \(i)", amount: 1.0)
        }
        XCTAssertGreaterThan(store.entries.count, VendlyStore.freeLimit)
    }

    func testDeleteRemovesEntry() {
        store.add(title: "ToDelete", amount: 2.0)
        let entry = store.entries[0]
        store.delete(entry)
        XCTAssertFalse(store.entries.contains(entry))
    }

    func testUpdateChangesFields() {
        store.add(title: "Original", amount: 1.0)
        var entry = store.entries[0]
        entry.title = "Updated"
        entry.amount = 9.0
        store.update(entry)
        XCTAssertEqual(store.entries[0].title, "Updated")
        XCTAssertEqual(store.entries[0].amount, 9.0)
    }

    func testFreeLimitAboveSeedCount() {
        XCTAssertGreaterThan(VendlyStore.freeLimit, 3)
    }
}
