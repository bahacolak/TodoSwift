import SwiftUI

// Background animation component
struct AnimatedBackground: View {
    let animateBackground: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(ThemeColors.primary.opacity(0.1))
                .frame(width: 300)
                .offset(x: -50, y: -100)
                .blur(radius: 50)
            
            Circle()
                .fill(ThemeColors.accent.opacity(0.1))
                .frame(width: 400)
                .offset(x: 150, y: 200)
                .blur(radius: 70)
        }
        .scaleEffect(animateBackground ? 1.2 : 1.0)
        .animation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true), value: animateBackground)
    }
}

// Welcome header component
struct WelcomeHeader: View {
    let animateIcon: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            // Icon with circles
            IconWithCircles(animateIcon: animateIcon)
            
            // Title
            VStack(spacing: 16) {
                Text("Welcome to")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(ThemeColors.textSecondary)
                
                Text("TodoList")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [ThemeColors.primary, ThemeColors.accent],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
        }
    }
}

// Icon with animated circles
struct IconWithCircles: View {
    let animateIcon: Bool
    
    var body: some View {
        ZStack {
            // Animated circles
            ForEach(0..<3) { index in
                Circle()
                    .stroke(ThemeColors.primary.opacity(0.2), lineWidth: 2)
                    .frame(width: 100 + CGFloat(index * 20), height: 100 + CGFloat(index * 20))
                    .scaleEffect(animateIcon ? 1.1 : 0.9)
                    .animation(.easeInOut(duration: 1.5).repeatForever().delay(Double(index) * 0.2), value: animateIcon)
            }
            
            // Icon
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [ThemeColors.primary, ThemeColors.accent],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
    }
}

// Feature row component
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(ThemeColors.primary.opacity(0.1))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(ThemeColors.primary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(ThemeColors.textPrimary)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(ThemeColors.textSecondary)
            }
            
            Spacer()
        }
    }
}

// Main WelcomeView
struct WelcomeView: View {
    @State private var showMainApp = false
    @State private var animateBackground = false
    @State private var animateIcon = false
    
    var body: some View {
        ZStack {
            if !showMainApp {
                // Animated background
                AnimatedBackground(animateBackground: animateBackground)
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    // Welcome header
                    WelcomeHeader(animateIcon: animateIcon)
                    
                    // Features section
                    VStack(spacing: 20) {
                        FeatureRow(icon: "tag.fill", title: "Smart Tags", description: "Organize tasks with custom tags")
                        FeatureRow(icon: "folder.fill", title: "Categories", description: "Group related tasks together")
                        FeatureRow(icon: "arrow.up.and.down", title: "Priority", description: "Arrange tasks by importance")
                    }
                    .padding(.horizontal, 32)
                    
                    Spacer()
                    
                    // Get Started Button
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showMainApp = true
                        }
                    }) {
                        Text("Get Started")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [ThemeColors.primary, ThemeColors.accent],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: ThemeColors.primary.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 32)
                }
                .transition(.move(edge: .leading))
            }
            
            if showMainApp {
                MainTabView()
                    .modelContainer(for: [Category.self, Item.self])
                    .transition(.move(edge: .trailing))
            }
        }
        .background(ThemeColors.background)
        .onAppear {
            withAnimation {
                animateBackground = true
                animateIcon = true
            }
        }
    }
}

#Preview {
    WelcomeView()
} 
