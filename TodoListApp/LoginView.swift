import SwiftUI
import SwiftData

struct LoginView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]
    @State private var email = ""
    @State private var password = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoggedIn = false
    @State private var showRegister = false
    @AppStorage("currentUserEmail") private var currentUserEmail: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Giriş Yap")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            VStack(spacing: 15) {
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                
                SecureField("Şifre", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: login) {
                    Text("Giriş Yap")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            HStack(spacing: 8) {
                Text("Hesabınız yok mu?")
                    .foregroundColor(.gray)
                
                Button(action: {
                    showRegister = true
                }) {
                    Text("Kayıt Olun")
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
            }
            .padding(.bottom, 20)
        }
        .padding(.top, 50)
        .alert("Hata", isPresented: $showAlert) {
            Button("Tamam", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .navigationDestination(isPresented: $isLoggedIn) {
            ContentView()
        }
        .navigationDestination(isPresented: $showRegister) {
            RegisterView()
        }
    }
    
    private func login() {
        guard !email.isEmpty, !password.isEmpty else {
            alertMessage = "Lütfen email ve şifre alanlarını doldurun."
            showAlert = true
            return
        }
        
        if users.first(where: { $0.email == email && $0.password == password }) != nil {
            currentUserEmail = email // Store the current user's email
            isLoggedIn = true
        } else {
            alertMessage = "Email veya şifre hatalı."
            showAlert = true
        }
    }
}

#Preview {
    NavigationStack {
        LoginView()
            .modelContainer(for: User.self)
    }
} 