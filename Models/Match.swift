import Foundation

// Match model for the entire application
public struct Match: Identifiable, Codable {
    public let id: String
    public let date: Date
    public let team1Id: String
    public let team2Id: String
    public let team1Name: String
    public let team2Name: String
    public let team1Score: Double?
    public let team2Score: Double?
    public let completed: Bool
    public let playersPoints: [String: Double] // Player ID to points
    public let winnerId: String?
    
    public typealias MatchStatus = Status
    
    public enum Status: String, Codable {
        case scheduled
        case inProgress
        case completed
        case canceled
    }
    
    public var status: MatchStatus {
        if completed {
            return .completed
        } else if Date() > date {
            return .inProgress
        } else {
            return .scheduled
        }
    }
    
    // Public initializer to ensure it can be created elsewhere
    public init(id: String, date: Date, team1Id: String, team2Id: String, 
                team1Name: String, team2Name: String, team1Score: Double?, 
                team2Score: Double?, completed: Bool, playersPoints: [String: Double], 
                winnerId: String?) {
        self.id = id
        self.date = date
        self.team1Id = team1Id
        self.team2Id = team2Id
        self.team1Name = team1Name
        self.team2Name = team2Name
        self.team1Score = team1Score
        self.team2Score = team2Score
        self.completed = completed
        self.playersPoints = playersPoints
        self.winnerId = winnerId
    }
}
