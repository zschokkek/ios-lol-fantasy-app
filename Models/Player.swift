import Foundation

public struct Player: Identifiable, Codable {
    public let id: String
    let name: String
    public let position: Position
    let team: String
    let region: Region
    let imageUrl: String?
    let fantasyPoints: Double
    let stats: PlayerStats
    
    public enum Position: String, Codable, CaseIterable {
        case TOP, JUNGLE, MID, ADC, SUPPORT, FLEX

    }
    
    enum Region: String, Codable, CaseIterable {
        case LCS
        case LEC
        case LPL
        case LCK
    }
}

public struct PlayerStats: Codable {
    let gamesPlayed: Int
    let kills: Int
    let deaths: Int
    let assists: Int
    let cs: Int
    let visionScore: Int
    
    var kda: Double {
        if deaths == 0 {
            return Double(kills + assists)
        }
        return Double(kills + assists) / Double(deaths)
    }
}
