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
            Text("Login")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            VStack(spacing: 15) {
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: login) {
                    Text("Login")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            VStack(spacing: 8) {
                Text("Don't have an account?")
                    .foregroundColor(.white)
                
                Button(action: {
                    showRegister = true
                }) {
                    Text("Register Now")
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Color.white)
                        .cornerRadius(8)
                }
            }
            .padding(.bottom, 32)
        }
        .padding(.top, 50)
        .background(ThemeColors.background)
        .alert("Error", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
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
            alertMessage = "Please fill in all fields."
            showAlert = true
            return
        }
        
        if users.first(where: { $0.email == email && $0.password == password }) != nil {
            currentUserEmail = email
            isLoggedIn = true
        } else {
            alertMessage = "Invalid email or password."
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