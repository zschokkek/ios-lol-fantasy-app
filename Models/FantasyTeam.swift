import Foundation

public struct FantasyTeam: Identifiable, Codable {
    public let id: String
    let name: String
    let ownerId: String
    let leagueId: String
    let leagueName: String
    let roster: [RosterSlot]
    let wins: Int
    let losses: Int
    var points: Double
    var players: [Player]
    
    
    // Method to find a player by position
    func player(forPosition position: Player.Position) -> Player? {
        return players.first(where: { $0.position == position })
    }
    
    struct RosterSlot: Identifiable, Codable {
        let id: String
        let position: Player.Position
        let playerId: String?
        let player: Player?
        let pointsThisWeek: Double
        
        // For creating an empty roster slot
        init(id: String, position: Player.Position) {
            self.id = id
            self.position = position
            self.playerId = nil
            self.player = nil
            self.pointsThisWeek = 0
        }
        
        // For creating a filled roster slot
        init(id: String, position: Player.Position, playerId: String, player: Player? = nil, pointsThisWeek: Double = 0) {
            self.id = id
            self.position = position
            self.playerId = playerId
            self.player = player
            self.pointsThisWeek = pointsThisWeek
        }
    }
    
    // Standard team structure with typical LoL positions
    static func createEmptyTeam(id: String, name: String, ownerId: String, leagueId: String, leagueName: String) -> FantasyTeam {
        return FantasyTeam(
            id: id,
            name: name,
            ownerId: ownerId,
            leagueId: leagueId,
            leagueName: leagueName,
            roster: [
                RosterSlot(id: UUID().uuidString, position: .TOP),
                RosterSlot(id: UUID().uuidString, position: .JUNGLE),
                RosterSlot(id: UUID().uuidString, position: .MID),
                RosterSlot(id: UUID().uuidString, position: .ADC),
                RosterSlot(id: UUID().uuidString, position: .SUPPORT),
                RosterSlot(id: UUID().uuidString, position: .FLEX)
            ],
            points: 0,
            players: []
        )
    }
    
    // Custom initializer to include players
    init(id: String, name: String, ownerId: String, leagueId: String, leagueName: String, roster: [RosterSlot], points: Double, players: [Player] = []) {
        self.id = id
        self.name = name
        self.ownerId = ownerId
        self.leagueId = leagueId
        self.leagueName = leagueName
        self.roster = roster
        self.points = points
        self.players = players
        self.wins = 0
        self.losses = 0
    }
}
