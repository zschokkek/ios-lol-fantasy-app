import Foundation

struct League: Identifiable, Codable {
    let id: String
    let name: String
    let status: String
    let ownerName: String
    let teams: [FantasyTeam]
    let currentWeek: Int
    let totalWeeks: Int
    let teamCount: Int
    let maxTeams: Int
    let schedule: [Matchup]
    let playerPool: [Player]
    let regions: [Player.Region]
    let creatorId: String
    let members: [User]
    let draftCompleted: Bool
    let draftInProgress: Bool
    let draftOrder: [String]  // Team IDs in draft order

    
    struct Matchup: Identifiable, Codable {
        let id: String
        let week: Int
        let homeTeamId: String
        let awayTeamId: String
        let homeTeam: FantasyTeam?
        let awayTeam: FantasyTeam?
        let completed: Bool
        let winner: String?
    }
    
    var isPublic: Bool {
        // For backward compatibility
        return true
    }
    
    var ownerId: String {
        // For backward compatibility
        return creatorId
    }
    
    var matches: [Matchup] {
        // For backward compatibility
        return schedule
    }
    
    // Add CodingKeys to specifically handle optional or backward compatibility properties
    enum CodingKeys: String, CodingKey {
        case id, name, status, teams, currentWeek, totalWeeks, schedule, playerPool, regions, ownerName
        case creatorId, members, draftCompleted, draftInProgress, draftOrder, teamCount, maxTeams
    }
}
