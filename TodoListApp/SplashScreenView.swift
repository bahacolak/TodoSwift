import SwiftUI
import SwiftData

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var iconScale = 0.0
    @State private var textOffset: CGFloat = 20
    @State private var textOpacity = 0.0
    @State private var checkmarkOffset: CGFloat = -20
    @State private var checkmarkOpacity = 0.0
    
    var body: some View {
        ZStack {
            if !isActive {
                ZStack {
                    ThemeColors.background
                        .ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        // Icon container
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [ThemeColors.primary, ThemeColors.accent],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 80, height: 80)
                                .shadow(color: ThemeColors.primary.opacity(0.3), radius: 10, x: 0, y: 5)
                            
                            Image(systemName: "checkmark")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)
                                .offset(y: checkmarkOffset)
                                .opacity(checkmarkOpacity)
                        }
                        .scaleEffect(iconScale)
                        
                        // App name
                        Text("TodoList")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [ThemeColors.primary, ThemeColors.accent],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .padding(.top, 16)
                            .offset(y: textOffset)
                            .opacity(textOpacity)
                    }
                }
                .transition(.move(edge: .bottom))
            }
            
            if isActive {
                WelcomeView()
                    .transition(.move(edge: .bottom))
            }
        }
        .onAppear {
            // Icon animation
            withAnimation(.spring(duration: 0.7, bounce: 0.5)) {
                iconScale = 1.0
            }
            
            // Checkmark animation
            withAnimation(.spring(duration: 0.5).delay(0.2)) {
                checkmarkOffset = 0
                checkmarkOpacity = 1.0
            }
            
            // Text animation
            withAnimation(.spring(duration: 0.6).delay(0.3)) {
                textOffset = 0
                textOpacity = 1.0
            }
            
            // Navigate to main screen
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                withAnimation(.easeInOut(duration: 0.6)) {
                    self.isActive = true
                }
            }
        }
    }
}

#Preview {
    let container: ModelContainer
    do {
        let schema = Schema([Item.self, Category.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: modelConfiguration)
    } catch {
        fatalError("Could not create preview container: \(error.localizedDescription)")
    }
    
    return SplashScreenView()
        .modelContainer(container)
} 