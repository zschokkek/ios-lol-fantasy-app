import Foundation

struct League: Identifiable, Codable {
    let id: String
    let name: String
    let teams: [FantasyTeam]
    let currentWeek: Int
    let totalWeeks: Int
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
}
