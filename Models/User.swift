import Foundation

public struct User: Identifiable, Codable {
    public let id: String
    let username: String
    let email: String
    let isAdmin: Bool
    let teams: [String]  // Team IDs
    let leagues: [String]  // League IDs
    let friends: [String]  // User IDs
    let pendingFriendRequests: [FriendRequest]
    let profileImageUrl: String?
    
    struct FriendRequest: Identifiable, Codable {
        let id: String
        let sender: String  // User ID
        let recipient: String  // User ID
        let status: Status
        let createdAt: Date
        
        enum Status: String, Codable {
            case pending
            case accepted
            
        }
    }
}


struct UserProfile: Identifiable, Codable {
    let id: String
    let teamsCount: Int
    let leaguesCount: Int
    let winRate: Double
    let favoritePlayers: [Player]
}
