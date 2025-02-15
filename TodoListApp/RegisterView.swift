import SwiftUI
import SwiftData

struct RegisterView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isRegistered = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Kayıt Ol")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            VStack(spacing: 15) {
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                
                SecureField("Şifre", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                SecureField("Şifre Tekrar", text: $confirmPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: register) {
                    Text("Kayıt Ol")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .padding(.top, 50)
        .alert("Bilgi", isPresented: $showAlert) {
            Button("Tamam", role: .cancel) { 
                if isRegistered {
                    // Navigate back to login
                    email = ""
                    password = ""
                    confirmPassword = ""
                }
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func register() {
        guard !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            alertMessage = "Lütfen tüm alanları doldurun."
            showAlert = true
            return
        }
        
        guard password == confirmPassword else {
            alertMessage = "Şifreler eşleşmiyor."
            showAlert = true
            return
        }
        
        guard !users.contains(where: { $0.email == email }) else {
            alertMessage = "Bu email adresi zaten kayıtlı."
            showAlert = true
            return
        }
        
        let user = User(email: email, password: password)
        modelContext.insert(user)
        
        alertMessage = "Kayıt başarılı! Giriş yapabilirsiniz."
        isRegistered = true
        showAlert = true
    }
} 