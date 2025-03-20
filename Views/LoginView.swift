import SwiftUI
import Combine

struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showingRegister = false
    
    @EnvironmentObject private var authManager: AuthManager
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 25) {
                // Logo and welcome
                VStack(spacing: 10) {
                    Image(systemName: "trophy.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.yellow)
                    
                    Text("LoL Fantasy")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Sign in to continue")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 30)
                
                // Login form
                VStack(spacing: 20) {
                    // Username field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Username")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        TextField("", text: $username)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                    }
                    
                    // Password field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        SecureField("", text: $password)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                    }
                    
                    // Error message
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundColor(.red)
                            .padding(.top, 10)
                    }
                    
                    // Login button
                    Button(action: login) {
                        ZStack {
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.yellow, Color.orange]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(10)
                                .frame(height: 50)
                            
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("SIGN IN")
                                    .font(.headline)
                                    .foregroundColor(.black)
                            }
                        }
                    }
                    .disabled(username.isEmpty || password.isEmpty || isLoading)
                    .opacity((username.isEmpty || password.isEmpty || isLoading) ? 0.6 : 1.0)
                    .padding(.top, 20)
                }
                
                // Register option
                HStack {
                    Text("Don't have an account?")
                        .foregroundColor(.gray)
                    
                    Button(action: {
                        showingRegister = true
                    }) {
                        Text("Register")
                            .fontWeight(.bold)
                            .foregroundColor(.yellow)
                    }
                }
                .padding(.top, 20)
                
                Spacer()
            }
            .padding(30)
        }
        .sheet(isPresented: $showingRegister) {
            RegisterView()
        }
    }
    
    private func login() {
        isLoading = true
        errorMessage = ""
        
        // This would typically call an API, but for now we'll use a dummy implementation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            
            // For testing purposes, we'll just check if the username and password are not empty
            if username.lowercased() == "test" && password == "password" {
                // In a real app, you would get a token from your API
                authManager.login(token: "dummy-token")
            } else {
                errorMessage = "Invalid username or password"
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthManager())
            .preferredColorScheme(.dark)
    }
}
