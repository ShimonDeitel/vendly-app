import Foundation

struct VendlyEntry: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var title: String
    var amount: Double
    var date: Date

    init(id: UUID = UUID(), title: String, amount: Double, date: Date = Date()) {
        self.id = id
        self.title = title
        self.amount = amount
        self.date = date
    }
}
