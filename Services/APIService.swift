import Foundation
import Combine

public class LoLFantasyAPIService {
    static let shared = LoLFantasyAPIService()
    
    private let baseURL = "https:/egbfantasy.com/api"
    private var authToken: String?
    
    private init() {}
    
    func setAuthToken(_ token: String) {
        self.authToken = token
    }
    
    func clearAuthToken() {
        self.authToken = nil
    }
    
    private func createRequest(_ path: String, method: String = "GET", body: [String: Any]? = nil) -> URLRequest {
        let url = URL(string: baseURL + path)!
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        // Add authentication header if we have a token
        if let token = authToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Add JSON content type for requests with a body
        if body != nil {
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        // Convert body dictionary to JSON data if provided
        if let body = body {
            let jsonData = try? JSONSerialization.data(withJSONObject: body)
            request.httpBody = jsonData
        }
        
        return request
    }
    
    // MARK: - Authentication
    
    func login(username: String, password: String) -> AnyPublisher<String, Error> {
        let body = ["username": username, "password": password]
        let request = createRequest("/auth/login", method: "POST", body: body)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: AuthResponse.self, decoder: JSONDecoder())
            .map { $0.token }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func register(username: String, email: String, password: String) -> AnyPublisher<String, Error> {
        let body = ["username": username, "email": email, "password": password]
        let request = createRequest("/auth/register", method: "POST", body: body)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: AuthResponse.self, decoder: JSONDecoder())
            .map { $0.token }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Users
    
    func getCurrentUser() -> AnyPublisher<User, Error> {
        let request = createRequest("/users/me")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: User.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Leagues
    
    func getLeagues() -> AnyPublisher<[League], Error> {
        let request = createRequest("/leagues")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: [League].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func getLeagueById(_ id: String) -> AnyPublisher<League, Error> {
        let request = createRequest("/leagues/\(id)")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: League.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    // MARK: - TrashTalk

    func getTrashTalk() -> AnyPublisher<[TrashTalk], Error> {
        let request = createRequest("/trashtalk") // Assuming this is the correct endpoint

        return URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: [TrashTalk].self, decoder: JSONDecoder())
            .catch { _ in Just([]).setFailureType(to: Error.self) } // Placeholder for empty response
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    // MARK: - Players
    
    func getPlayers() -> AnyPublisher<[Player], Error> {
        let request = createRequest("/players")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: [Player].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func getPlayerById(_ id: String) -> AnyPublisher<Player, Error> {
        let request = createRequest("/players/\(id)")

        return URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: Player.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Teams
    
    func getTeamById(_ id: String) -> AnyPublisher<FantasyTeam, Error> {
        let request = createRequest("/teams/\(id)")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: FantasyTeam.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        
    }
    
    func getUserTeams() -> AnyPublisher<[FantasyTeam], Error> {
        let request = createRequest("/users/user123/teams")

        return URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: [FantasyTeam].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    // MARK: - Helper Types
    
    func getUserProfile(userId: String) -> AnyPublisher<UserProfile, Error> {
        let request = createRequest("/users/\(userId)/profile")

        return URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: UserProfile.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    private struct AuthResponse: Codable {
        let token: String
        let user: User
    }
}
