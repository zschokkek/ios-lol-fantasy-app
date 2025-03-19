import Foundation

struct FantasyTeam: Identifiable, Codable {
    let id: String
    let name: String
    let owner: String
    let players: [Player.Position: Player?]
    let totalPoints: Double
    let leagueId: String
    
    var filledPositions: Int {
        return players.values.compactMap { $0 }.count
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, owner, players, totalPoints, leagueId
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        owner = try container.decode(String.self, forKey: .owner)
        
        // Handle players dictionary with potential null values
        let playersDict = try container.decode([String: Player?].self, forKey: .players)
        var positionPlayers: [Player.Position: Player?] = [:]
        
        for (key, player) in playersDict {
            if let position = Player.Position(rawValue: key) {
                positionPlayers[position] = player
            }
        }
        
        players = positionPlayers
        totalPoints = try container.decode(Double.self, forKey: .totalPoints)
        leagueId = try container.decode(String.self, forKey: .leagueId)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(owner, forKey: .owner)
        
        // Convert position enum keys to strings for encoding
        var stringKeyedPlayers: [String: Player?] = [:]
        for (position, player) in players {
            stringKeyedPlayers[position.rawValue] = player
        }
        
        try container.encode(stringKeyedPlayers, forKey: .players)
        try container.encode(totalPoints, forKey: .totalPoints)
        try container.encode(leagueId, forKey: .leagueId)
    }
}
