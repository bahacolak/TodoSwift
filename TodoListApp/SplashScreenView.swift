import SwiftUI
import SwiftData

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var opacity = 0.0
    
    var body: some View {
        NavigationStack {
            if isActive {
                WelcomeView()
            } else {
                VStack {
                    Text("TodoList")
                        .font(.system(size: 48))
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                .opacity(opacity)
                .onAppear {
                    withAnimation(.easeIn(duration: 1.0)) {
                        self.opacity = 1.0
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        withAnimation {
                            self.isActive = true
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    SplashScreenView()
        .modelContainer(for: [Category.self, Item.self])
} 