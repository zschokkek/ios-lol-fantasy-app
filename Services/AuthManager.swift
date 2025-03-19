import Foundation
import Combine

class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    
    private let tokenKey = "auth_token"
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Check for existing token on launch
        if let token = UserDefaults.standard.string(forKey: tokenKey) {
            APIService.shared.setAuthToken(token)
            isAuthenticated = true
            fetchCurrentUser()
        }
    }
    
    func login(token: String) {
        APIService.shared.setAuthToken(token)
        UserDefaults.standard.set(token, forKey: tokenKey)
        isAuthenticated = true
        fetchCurrentUser()
    }
    
    func logout() {
        APIService.shared.clearAuthToken()
        UserDefaults.standard.removeObject(forKey: tokenKey)
        isAuthenticated = false
        currentUser = nil
    }
    
    private func fetchCurrentUser() {
        isLoading = true
        
        // This would be a call to get the current user's profile
        // For now, we'll create a placeholder user
        // In a real app, you would call an API endpoint like /api/users/me
        
        // Simulating API call delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.currentUser = User(
                id: "user123",
                username: "summoner",
                email: "summoner@example.com",
                isAdmin: false,
                teams: [],
                leagues: [],
                friends: [],
                pendingFriendRequests: []
            )
            self?.isLoading = false
        }
    }
}
