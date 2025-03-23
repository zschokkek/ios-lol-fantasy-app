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
    
    
    // MARK: - League API Methods
    func getLeagues(endpoint: String) -> AnyPublisher<[League], Error> {
        fetchData(endpoint: endpoint)
    }

    func getLeagueById(endpoint: String) -> AnyPublisher<League, Error> {
        fetchData(endpoint: endpoint)
    }

    func createLeague(leagueData: [String: Any]) -> AnyPublisher<League, Error> {
        fetchData(endpoint: "/leagues", method: "POST", body: leagueData)
    }

    func joinLeague(leagueId: String, teamName: String) -> AnyPublisher<League, Error> {
        fetchData(endpoint: "/leagues/\(leagueId)/join", method: "POST", body: ["teamName": teamName])
    }
    
    
    
// MARK: - Players API Calls
    func getPlayers() -> AnyPublisher<[Player.PlayerInfo], Error> {
        let url = URL(string: "\(baseURL)/players")!

        return URLSession.shared.dataTaskPublisher(for: url)
            .map { data, _ in
                print("sRaw JSON data: \(String(data: data, encoding: .utf8) ?? "Invalid data")")
                return data
            }
            .decode(type: [Player.PlayerInfo].self, decoder: JSONDecoder())  // Changed from Player.Stats to PlayerInfo
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
    
    // MARK: - Core API Request
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
    // MARK: - Core API Request
    private func fetchData<T: Decodable>(endpoint: String, method: String = "GET", body: [String: Any]? = nil) -> AnyPublisher<T, Error> {
        guard let url = URL(string: baseURL + endpoint) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = method

        if let body = body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: T.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
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
    
    // MARK: - Leagues
    func fetchLeagues() -> AnyPublisher<[League], Error> {
        let url = URL(string: "\(baseURL)/leagues")!

        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }

                // 🚨 Debugging step: Confirm data length and content type
                print("🔎 Data Length: \(data.count) bytes")
                if let httpResponse = response as? HTTPURLResponse {
                    print("🔎 Content-Type: \(httpResponse.allHeaderFields["Content-Type"] ?? "Unknown")")
                }

                // 🚨 JSONSerialization to inspect structure before decoding
                do {
                    let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                    print("🔎 JSON Object Structure: \(jsonObject)")
                } catch {
                    print("❌ JSON Serialization Error: \(error)")
                }

                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                // 🚨 Add this to confirm decoding errors
                do {
                    let leagues = try decoder.decode([League].self, from: data)
                    print("✅ Successfully decoded leagues: \(leagues.count)")
                    return leagues
                } catch {
                    print("❌ Decoding Error: \(error)")
                    throw error
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }


   func createLeague(leagueData: [String: Any], completion: @escaping (Result<League, Error>) -> Void) {
       let url = URL(string: "\(baseURL)/leagues")!
       var request = URLRequest(url: url)
       request.httpMethod = "POST"
       request.setValue("application/json", forHTTPHeaderField: "Content-Type")
       request.httpBody = try? JSONSerialization.data(withJSONObject: leagueData)

       URLSession.shared.dataTask(with: request) { data, response, error in
           if let error = error {
               completion(.failure(error))
               return
           }
           guard let data = data else {
               completion(.failure(NSError(domain: "No data", code: -1)))
               return
           }
           do {
               let newLeague = try JSONDecoder().decode(League.self, from: data)
               completion(.success(newLeague))
           } catch {
               completion(.failure(error))
           }
       }.resume()
   }

   func joinLeague(leagueId: String, teamName: String, completion: @escaping (Result<League, Error>) -> Void) {
       let url = URL(string: "\(baseURL)/leagues/\(leagueId)/join")!
       var request = URLRequest(url: url)
       request.httpMethod = "POST"
       request.setValue("application/json", forHTTPHeaderField: "Content-Type")
       let body: [String: Any] = ["teamName": teamName]
       request.httpBody = try? JSONSerialization.data(withJSONObject: body)

       URLSession.shared.dataTask(with: request) { data, response, error in
           if let error = error {
               completion(.failure(error))
               return
           }
           guard let data = data else {
               completion(.failure(NSError(domain: "No data", code: -1)))
               return
           }
           do {
               let updatedLeague = try JSONDecoder().decode(League.self, from: data)
               completion(.success(updatedLeague))
           } catch {
               completion(.failure(error))
           }
       }.resume()
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
