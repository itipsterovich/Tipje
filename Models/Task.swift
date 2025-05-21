import Foundation
import SwiftData

@Model
final class Task: Identifiable {
    @Attribute(.unique) var id: UUID = UUID()
    var kind: TaskKind
    var title: String
    var peanuts: Int
    var category: Category
    var createdAt: Date
    var isSelected: Bool
    var isCompleted: Bool
    var inBasket: Bool
    // TODO: Add kidID for multi-profile support
    
    init(kind: TaskKind, title: String, peanuts: Int, category: Category, createdAt: Date = Date(), isSelected: Bool = false, isCompleted: Bool = false, inBasket: Bool = false) {
        self.kind = kind
        self.title = title
        self.peanuts = peanuts
        self.category = category
        self.createdAt = createdAt
        self.isSelected = isSelected
        self.isCompleted = isCompleted
        self.inBasket = inBasket
    }
}

enum TaskKind: String, Codable, CaseIterable {
    case rule, chore, reward
}

enum Category: String, Codable, CaseIterable {
    case security, respect, fun
    // Extendable
} 