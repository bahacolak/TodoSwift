import SwiftUI

struct ThemeColors {
    static let primary = Color("AccentColor")
    
    static var background: Color {
        Color(.systemBackground)
    }
    
    static var secondaryBackground: Color {
        Color(.secondarySystemBackground)
    }
    
    static var surface: Color {
        Color(.tertiarySystemBackground)
    }
    
    static var textPrimary: Color {
        Color(.label)
    }
    
    static var textSecondary: Color {
        Color(.secondaryLabel)
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
    
    static var accent: Color {
        Color(.systemIndigo)
    }
} 