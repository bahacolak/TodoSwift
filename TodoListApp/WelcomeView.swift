import SwiftUI

struct WelcomeView: View {
    @State private var showLogin = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                ThemeColors.background
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    Text("Welcome to TodoList!")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.blue)
                        .multilineTextAlignment(.center)
                    
                    Text("Organize, track, and complete your tasks.")
                        .font(.system(size: 18))
                        .foregroundColor(.blue.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    
                    Spacer()
                    
                    Button(action: {
                        showLogin = true
                    }) {
                        Text("Get Started")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(red: 52/255, green: 199/255, blue: 89/255), Color(red: 48/255, green: 176/255, blue: 82/255)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 50)
                }
            }
            .navigationDestination(isPresented: $showLogin) {
                LoginView()
            }
        }
    }
}

#Preview {
    WelcomeView()
} 
