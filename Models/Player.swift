import Foundation

struct Player: Identifiable, Codable {
    let id: String
    let name: String
    let position: Position
    let team: String
    let region: Region
    let imageUrl: String?
    let fantasyPoints: Double
    let stats: PlayerStats
    
    enum Position: String, Codable, CaseIterable {
        case TOP
        case JUNGLE
        case MID
        case ADC
        case SUPPORT
        case FLEX
    }
    
    enum Region: String, Codable, CaseIterable {
        case LCS
        case LEC
        case LPL
        case LCK
    }
}

struct PlayerStats: Codable {
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
