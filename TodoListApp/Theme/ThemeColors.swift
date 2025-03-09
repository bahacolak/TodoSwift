import SwiftUI

struct ThemeColors {
    static let primary = Color(light: "#4A90E2", dark: "#4A90E2")
    static let accent = Color(light: "#50E3C2", dark: "#50E3C2")
    static let background = Color(light: "#F5F6FA", dark: "#1A1A1A")
    static let textPrimary = Color(light: "#2D3436", dark: "#FFFFFF")
    static let textSecondary = Color(light: "#636E72", dark: "#A0A0A0")
    
    // Category default colors - These will remain the same in both modes
    static let categoryColors: [Color] = [
        Color(light: "#FF6B6B", dark: "#FF6B6B"),  // Red
        Color(light: "#4FACFE", dark: "#4FACFE"),  // Blue
        Color(light: "#43E97B", dark: "#43E97B"),  // Green
        Color(light: "#F3A953", dark: "#F3A953"),  // Orange
        Color(light: "#A362F7", dark: "#A362F7"),  // Purple
        Color(light: "#2ED1A2", dark: "#2ED1A2"),  // Teal
        Color(light: "#FE6694", dark: "#FE6694"),  // Pink
        Color(light: "#747D8C", dark: "#747D8C")   // Gray
    ]
    
    static var secondaryBackground: Color {
        Color(light: "#FFFFFF", dark: "#2C2C2C")
    }
    
    static var surface: Color {
        Color(light: "#FFFFFF", dark: "#2C2C2C")
    }
    
    static var divider: Color {
        Color(light: "#E0E0E0", dark: "#3A3A3A")
    }
    
    static var success: Color {
        Color(light: "#4CAF50", dark: "#4CAF50")
    }
    
    static var warning: Color {
        Color(light: "#FF5252", dark: "#FF5252")
    }
}

// Helper extension for hex colors with dark mode support
extension Color {
    init(light: String, dark: String) {
        self.init(uiColor: UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor(hex: dark) ?? .black
            } else {
                return UIColor(hex: light) ?? .white
            }
        })
    }
}

// Helper extension for UIColor to support hex initialization
extension UIColor {
    convenience init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
} 