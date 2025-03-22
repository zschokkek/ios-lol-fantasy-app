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
}
