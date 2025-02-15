import Foundation
import SwiftData
import SwiftUI

@Model
final class Category {
    var id: String
    var name: String
    var color: String // Store color as a hex string
    @Relationship(inverse: \Item.category) var items: [Item]
    
    init(name: String, color: String = "#007AFF") {
        self.id = UUID().uuidString
        self.name = name
        self.color = color
        self.items = []
    }
    
    var uiColor: Color {
        Color(hex: color) ?? .blue
    }
}

// Color extension to support hex colors
extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }
        
        self.init(
            .sRGB,
            red: Double((rgb & 0xFF0000) >> 16) / 255.0,
            green: Double((rgb & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgb & 0x0000FF) / 255.0,
            opacity: 1.0
        )
    }
} 