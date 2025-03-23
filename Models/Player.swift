import Foundation

public struct Player: Identifiable, Codable {
    enum Position: String, CaseIterable, Codable {
        case TOP, JUNGLE, MID, ADC, SUPPORT, FLEX
    }

    enum Region: String, CaseIterable, Codable {
        case KOREA, AMERICAS, EUROPE, CHINA
    }

    struct Stats: Codable {
        let kills: Int
        let deaths: Int
        let assists: Int
        let cs: Int
        let visionScore: Int
        let baronKills: Int
        let dragonKills: Int
        let turretKills: Int
        let gamesPlayed: Int
    }

    public let id: String
    let name: String
    let position: Position
    let team: String
    let region: Region
    let stats: Stats
    let fantasyPoints: Double
    
    struct PlayerInfo: Codable {
        let name: String
        let position: String
        let team: String
        let region: String
    }

}

// MARK: - Extension for Conversion
extension Player {
    init(from playerInfo: Player.PlayerInfo) {
        self.id = UUID().uuidString // Generate a new ID since `PlayerInfo` has no `id`
        self.name = playerInfo.name
        self.team = playerInfo.team
        self.position = Player.Position(rawValue: playerInfo.position) ?? .FLEX
        self.region = Player.Region(rawValue: playerInfo.region) ?? .AMERICAS
        self.stats = Player.Stats( // Placeholder stats since PlayerInfo doesn't include them
            kills: 0, deaths: 0, assists: 0, cs: 0,
            visionScore: 0, baronKills: 0,
            dragonKills: 0, turretKills: 0, gamesPlayed: 0
        )
        self.fantasyPoints = 0.0 // Set a default score or modify as needed
    }
}
