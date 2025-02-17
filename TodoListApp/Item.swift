import Foundation
import SwiftData
import SwiftUI

@Model
final class Item {
    @Attribute(.unique) var id: String
    var title: String
    var isCompleted: Bool
    var timestamp: Date
    var priority: Priority
    var order: Int
    var tags: [String] = []  // Store tags directly as array
    var category: Category?
    
    init(title: String = "", isCompleted: Bool = false, timestamp: Date = .now, priority: Priority = .normal, order: Int = 0, tags: [String] = [], category: Category? = nil) {
        self.id = UUID().uuidString
        self.title = title
        self.isCompleted = isCompleted
        self.timestamp = timestamp
        self.priority = priority
        self.order = order
        self.tags = tags
        self.category = category
    }
    
    enum Priority: Int, Codable {
        case low
        case normal
        case high
        
        var color: Color {
            switch self {
            case .low: return ThemeColors.success
            case .normal: return ThemeColors.primary
            case .high: return ThemeColors.warning
            }
        }
    }
}
