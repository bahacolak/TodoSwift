import SwiftUI
import SwiftData

struct RegisterView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var users: [User]
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isRegistered = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Register")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(ThemeColors.textPrimary)
            
            VStack(spacing: 15) {
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                SecureField("Confirm Password", text: $confirmPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: register) {
                    Text("Register")
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
        .padding(.top, 50)
        .background(ThemeColors.background)
        .alert("Info", isPresented: $showAlert) {
            Button("OK", role: .cancel) { 
                if isRegistered {
                    dismiss()
                }
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func register() {
        guard !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            alertMessage = "Please fill in all fields."
            showAlert = true
            return
        }
        
        guard password == confirmPassword else {
            alertMessage = "Passwords do not match."
            showAlert = true
            return
        }
        
        guard !users.contains(where: { $0.email == email }) else {
            alertMessage = "This email is already registered."
            showAlert = true
            return
        }
        
        let user = User(email: email, password: password)
        modelContext.insert(user)
        
        alertMessage = "Registration successful! You can now login."
        isRegistered = true
        showAlert = true
    }
}

#Preview {
    NavigationStack {
        RegisterView()
            .modelContainer(for: User.self)
    }
} 