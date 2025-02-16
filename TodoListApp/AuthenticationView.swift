import SwiftUI
import SwiftData

struct AuthenticationView: View {
    @State private var showLogin = false
    @State private var showRegister = false
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Text("Todo List")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(ThemeColors.textPrimary)
            
            VStack(spacing: 15) {
                Button(action: {
                    showLogin = true
                }) {
                    Text("Giriş Yap")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(ThemeColors.primary)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    showRegister = true
                }) {
                    Text("Kayıt Ol")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(ThemeColors.primary)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .background(ThemeColors.background)
        .navigationDestination(isPresented: $showLogin) {
            LoginView()
        }
        .navigationDestination(isPresented: $showRegister) {
            RegisterView()
        }
    }
} 