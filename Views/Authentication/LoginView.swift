import SwiftUI
import Combine

// Local error types to fix build errors
fileprivate enum AuthError: Error {
    case unauthorized
    case invalidCredentials
    case networkError
    case httpError(Int)
    case unknown
}

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @EnvironmentObject private var authManager: AuthManager
    @State private var showingRegistration = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 30) {
                    // Logo and header
                    VStack(spacing: 15) {
                        Image(systemName: "gamecontroller.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.yellow)
                        
                        Text("LoL Fantasy")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Login to your account")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 50)
                    
                    // Login form
                    VStack(spacing: 20) {
                        TextField("Username", text: $viewModel.username)
                            .textFieldStyle(RoundedTextFieldStyle())
                        
                        SecureField("Password", text: $viewModel.password)
                            .textFieldStyle(RoundedTextFieldStyle())
                        
                        if !viewModel.errorMessage.isEmpty {
                            Text(viewModel.errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                                .padding(.top, -10)
                        }
                        
                        Button(action: {
                            viewModel.login { token in
                                authManager.login(token: token)
                            }
                        }) {
                            Text("LOGIN")
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.yellow, Color.orange]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(10)
                        }
                        .disabled(viewModel.isLoading)
                        .overlay(
                            Group {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                }
                            }
                        )
                    }
                    .padding(.horizontal, 30)
                    
                    // Registration link
                    Button(action: {
                        showingRegistration = true
                    }) {
                        Text("Don't have an account? Sign up")
                            .foregroundColor(.yellow)
                            .underline()
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingRegistration) {
                RegisterView()
                    .environmentObject(authManager)
            }
        }
    }
}

struct RoundedTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
            .foregroundColor(.white)
    }
}

class LoginViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    func login(completion: @escaping (String) -> Void) {
        guard !username.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter both username and password"
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // For testing purposes, always succeed with a fake token
            self.isLoading = false
            completion("token_123")
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
