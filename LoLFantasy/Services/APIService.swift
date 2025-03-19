import Foundation
import Combine

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case decodingError(Error)
    case networkError(Error)
    case unauthorized
    case unknown
}

class APIService {
    static let shared = APIService()
    
    private let baseURL = "http://localhost:5000/api"
    private var authToken: String?
    
    private init() {}
    
    func setAuthToken(_ token: String) {
        self.authToken = token
    }
    
    func clearAuthToken() {
        self.authToken = nil
    }
    
    // MARK: - Authentication
    
    func login(username: String, password: String) -> AnyPublisher<String, APIError> {
        let endpoint = "\(baseURL)/users/login"
        let body: [String: Any] = ["username": username, "password": password]
        
        return request(endpoint: endpoint, method: "POST", body: body)
            .map { (data: [String: Any]) -> String in
                guard let token = data["token"] as? String else {
                    throw APIError.decodingError(NSError(domain: "APIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Token not found in response"]))
                }
                return token
            }
            .eraseToAnyPublisher()
    }
    
    func register(username: String, email: String, password: String) -> AnyPublisher<String, APIError> {
        let endpoint = "\(baseURL)/users/register"
        let body: [String: Any] = ["username": username, "email": email, "password": password]
        
        return request(endpoint: endpoint, method: "POST", body: body)
            .map { (data: [String: Any]) -> String in
                guard let token = data["token"] as? String else {
                    throw APIError.decodingError(NSError(domain: "APIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Token not found in response"]))
                }
                return token
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Players
    
    func getPlayers() -> AnyPublisher<[Player], APIError> {
        let endpoint = "\(baseURL)/players"
        
        return request(endpoint: endpoint, method: "GET")
            .decode(type: [Player].self, decoder: JSONDecoder())
            .mapError { error in
                if let apiError = error as? APIError {
                    return apiError
                }
                return APIError.decodingError(error)
            }
            .eraseToAnyPublisher()
    }
    
    func getPlayerById(_ id: String) -> AnyPublisher<Player, APIError> {
        let endpoint = "\(baseURL)/players/\(id)"
        
        return request(endpoint: endpoint, method: "GET")
            .decode(type: Player.self, decoder: JSONDecoder())
            .mapError { error in
                if let apiError = error as? APIError {
                    return apiError
                }
                return APIError.decodingError(error)
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Teams
    
    func getTeams() -> AnyPublisher<[FantasyTeam], APIError> {
        let endpoint = "\(baseURL)/teams"
        
        return request(endpoint: endpoint, method: "GET")
            .decode(type: [FantasyTeam].self, decoder: JSONDecoder())
            .mapError { error in
                if let apiError = error as? APIError {
                    return apiError
                }
                return APIError.decodingError(error)
            }
            .eraseToAnyPublisher()
    }
    
    func getTeamById(_ id: String) -> AnyPublisher<FantasyTeam, APIError> {
        let endpoint = "\(baseURL)/teams/\(id)"
        
        return request(endpoint: endpoint, method: "GET")
            .decode(type: FantasyTeam.self, decoder: JSONDecoder())
            .mapError { error in
                if let apiError = error as? APIError {
                    return apiError
                }
                return APIError.decodingError(error)
            }
            .eraseToAnyPublisher()
    }
    
    func createTeam(name: String, leagueId: String) -> AnyPublisher<FantasyTeam, APIError> {
        let endpoint = "\(baseURL)/teams"
        let body: [String: Any] = ["name": name, "leagueId": leagueId]
        
        return request(endpoint: endpoint, method: "POST", body: body)
            .decode(type: FantasyTeam.self, decoder: JSONDecoder())
            .mapError { error in
                if let apiError = error as? APIError {
                    return apiError
                }
                return APIError.decodingError(error)
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Leagues
    
    func getLeagues() -> AnyPublisher<[League], APIError> {
        let endpoint = "\(baseURL)/leagues"
        
        return request(endpoint: endpoint, method: "GET")
            .decode(type: [League].self, decoder: JSONDecoder())
            .mapError { error in
                if let apiError = error as? APIError {
                    return apiError
                }
                return APIError.decodingError(error)
            }
            .eraseToAnyPublisher()
    }
    
    func getLeagueById(_ id: String) -> AnyPublisher<League, APIError> {
        let endpoint = "\(baseURL)/leagues/\(id)"
        
        return request(endpoint: endpoint, method: "GET")
            .decode(type: League.self, decoder: JSONDecoder())
            .mapError { error in
                if let apiError = error as? APIError {
                    return apiError
                }
                return APIError.decodingError(error)
            }
            .eraseToAnyPublisher()
    }
    
    func createLeague(name: String, maxTeams: Int, regions: [Player.Region]) -> AnyPublisher<League, APIError> {
        let endpoint = "\(baseURL)/leagues"
        let body: [String: Any] = [
            "name": name,
            "maxTeams": maxTeams,
            "regions": regions.map { $0.rawValue }
        ]
        
        return request(endpoint: endpoint, method: "POST", body: body)
            .decode(type: League.self, decoder: JSONDecoder())
            .mapError { error in
                if let apiError = error as? APIError {
                    return apiError
                }
                return APIError.decodingError(error)
            }
            .eraseToAnyPublisher()
    }
    
    func joinLeague(leagueId: String, teamName: String) -> AnyPublisher<League, APIError> {
        let endpoint = "\(baseURL)/leagues/\(leagueId)/join"
        let body: [String: Any] = ["teamName": teamName]
        
        return request(endpoint: endpoint, method: "POST", body: body)
            .decode(type: League.self, decoder: JSONDecoder())
            .mapError { error in
                if let apiError = error as? APIError {
                    return apiError
                }
                return APIError.decodingError(error)
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - TrashTalk Methods
    
    func getTrashTalk(leagueId: String) -> AnyPublisher<[TrashTalk], APIError> {
        let endpoint = "\(baseURL)/leagues/\(leagueId)/trash-talk"
        
        return request(endpoint: endpoint, method: "GET")
            .decode(type: [TrashTalk].self, decoder: JSONDecoder())
            .mapError { error in
                if let apiError = error as? APIError {
                    return apiError
                }
                return APIError.decodingError(error)
            }
            .eraseToAnyPublisher()
    }
    
    func createTrashTalk(leagueId: String, content: String) -> AnyPublisher<TrashTalk, APIError> {
        let endpoint = "\(baseURL)/leagues/\(leagueId)/trash-talk"
        let body: [String: Any] = [
            "content": content
        ]
        
        return request(endpoint: endpoint, method: "POST", body: body)
            .decode(type: TrashTalk.self, decoder: JSONDecoder())
            .mapError { error in
                if let apiError = error as? APIError {
                    return apiError
                }
                return APIError.decodingError(error)
            }
            .eraseToAnyPublisher()
    }
    
    func updateTrashTalk(id: String, content: String) -> AnyPublisher<TrashTalk, APIError> {
        let endpoint = "\(baseURL)/trash-talk/\(id)"
        let body: [String: Any] = [
            "content": content
        ]
        
        return request(endpoint: endpoint, method: "PUT", body: body)
            .decode(type: TrashTalk.self, decoder: JSONDecoder())
            .mapError { error in
                if let apiError = error as? APIError {
                    return apiError
                }
                return APIError.decodingError(error)
            }
            .eraseToAnyPublisher()
    }
    
    func deleteTrashTalk(id: String) -> AnyPublisher<Bool, APIError> {
        let endpoint = "\(baseURL)/trash-talk/\(id)"
        
        return request(endpoint: endpoint, method: "DELETE")
            .map { _ in true }
            .mapError { error in
                if let apiError = error as? APIError {
                    return apiError
                }
                return APIError.decodingError(error)
            }
            .eraseToAnyPublisher()
    }
    
    func likeTrashTalk(id: String) -> AnyPublisher<TrashTalk, APIError> {
        let endpoint = "\(baseURL)/trash-talk/\(id)/like"
        
        return request(endpoint: endpoint, method: "POST")
            .decode(type: TrashTalk.self, decoder: JSONDecoder())
            .mapError { error in
                if let apiError = error as? APIError {
                    return apiError
                }
                return APIError.decodingError(error)
            }
            .eraseToAnyPublisher()
    }
    
    func unlikeTrashTalk(id: String) -> AnyPublisher<TrashTalk, APIError> {
        let endpoint = "\(baseURL)/trash-talk/\(id)/unlike"
        
        return request(endpoint: endpoint, method: "POST")
            .decode(type: TrashTalk.self, decoder: JSONDecoder())
            .mapError { error in
                if let apiError = error as? APIError {
                    return apiError
                }
                return APIError.decodingError(error)
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Generic Request
    
    private func request<T: Decodable>(endpoint: String, method: String, body: [String: Any]? = nil) -> AnyPublisher<T, APIError> {
        guard let url = URL(string: endpoint) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = authToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: body)
            } catch {
                return Fail(error: APIError.networkError(error)).eraseToAnyPublisher()
            }
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }
                
                if httpResponse.statusCode == 401 {
                    throw APIError.unauthorized
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    throw APIError.httpError(httpResponse.statusCode)
                }
                
                return data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error in
                if let apiError = error as? APIError {
                    return apiError
                } else if error is DecodingError {
                    return APIError.decodingError(error)
                } else {
                    return APIError.networkError(error)
                }
            }
            .eraseToAnyPublisher()
    }
}
