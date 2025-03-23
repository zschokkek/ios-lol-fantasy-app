import Foundation

public struct League: Identifiable, Decodable {
    public var id: String
    let creatorId: String?
    let name: String
    let description: String?
    let teams: [FantasyTeam]?
    let maxTeams: Int
    let schedule: [String]?
    let currentWeek: Int
    let standings: [Standing]?
    let playerPool: [String]?
    let memberIds: [String]?
    let isPublic: Bool
    let regions: [String]?
    
    // Adding Matchup struct for compatibility with existing code
    struct Matchup: Identifiable, Codable {
        let id: String
        let week: Int
        let homeTeamId: String
        let awayTeamId: String
        let homeTeam: FantasyTeam?
        let awayTeam: FantasyTeam?
        let completed: Bool
        let winner: String?
        
        enum CodingKeys: String, CodingKey {
            case id, week, homeTeamId, awayTeamId, homeTeam, awayTeam, completed, winner
        }
    }
    
    struct Standing: Codable {
        let team: FantasyTeam
        let wins: Int
        let losses: Int
        let totalPoints: Int
        
        enum CodingKeys: String, CodingKey {
            case team, wins, losses, totalPoints
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case creatorId
        case name
        case description
        case teams
        case maxTeams
        case schedule
        case currentWeek
        case standings
        case playerPool
        case memberIds
        case isPublic
        case regions
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        creatorId = try container.decodeIfPresent(String.self, forKey: .creatorId)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        teams = try container.decodeIfPresent([FantasyTeam].self, forKey: .teams)
        maxTeams = try container.decodeIfPresent(Int.self, forKey: .maxTeams) ?? 0
        schedule = try container.decodeIfPresent([String].self, forKey: .schedule)
        currentWeek = try container.decodeIfPresent(Int.self, forKey: .currentWeek) ?? 1
        standings = try container.decodeIfPresent([Standing].self, forKey: .standings)
        playerPool = try container.decodeIfPresent([String].self, forKey: .playerPool)
        memberIds = try container.decodeIfPresent([String].self, forKey: .memberIds)
        isPublic = try container.decodeIfPresent(Bool.self, forKey: .isPublic) ?? false
        regions = try container.decodeIfPresent([String].self, forKey: .regions)
    }
}
