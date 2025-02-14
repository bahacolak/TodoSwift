import Foundation
import SwiftData
import SwiftUI

@Model
final class Item {
    @Attribute(.unique) var id: String?
    var title: String
    var isCompleted: Bool
    var timestamp: Date
    var priority: Priority
    var order: Int?
    
    init(title: String = "", isCompleted: Bool = false, timestamp: Date = .now, priority: Priority = .normal, order: Int = 0) {
        self.id = UUID().uuidString
        self.title = title
        self.isCompleted = isCompleted
        self.timestamp = timestamp
        self.priority = priority
        self.order = order
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
