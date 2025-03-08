import SwiftUI

struct ThemeColors {
    static let primary = Color(hex: "#4A90E2")
    static let accent = Color(hex: "#50E3C2")
    static let background = Color(hex: "#F5F6FA")
    static let textPrimary = Color(hex: "#2D3436")
    static let textSecondary = Color(hex: "#636E72")
    
    // Category default colors
    static let categoryColors: [Color] = [
        Color(hex: "#FF6B6B"),  // Red
        Color(hex: "#4FACFE"),  // Blue
        Color(hex: "#43E97B"),  // Green
        Color(hex: "#F3A953"),  // Orange
        Color(hex: "#A362F7"),  // Purple
        Color(hex: "#2ED1A2"),  // Teal
        Color(hex: "#FE6694"),  // Pink
        Color(hex: "#747D8C")   // Gray
    ]
    
    static var secondaryBackground: Color {
        Color(.secondarySystemBackground)
    }
    
    static var surface: Color {
        Color(.tertiarySystemBackground)
    }
    
    static var divider: Color {
        Color(.separator)
    }
    
    static var success: Color {
        Color(.systemGreen)
    }
    
    static var warning: Color {
        Color(.systemRed)
    }
} 