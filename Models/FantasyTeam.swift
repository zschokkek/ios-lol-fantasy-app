import Foundation

public struct FantasyTeam: Identifiable, Codable {
    public let id: String
    let name: String
    let leagueId: String?
    let totalPoints: Int
    let weeklyPoints: [String: AnyCodable]?
    let players: PlayersPositions?
    
    // Adding the RosterSlot for compatibility with existing code
    struct RosterSlot: Identifiable, Codable {
        let id: String
        let position: Player.Position
        let playerId: String?
        let pointsThisWeek: Double
        let player: Player?
        
        enum CodingKeys: String, CodingKey {
            case id, position, playerId, pointsThisWeek, player
        }
    }
    
    // Structure that matches the players JSON format in your data
    struct PlayersPositions: Codable {
        let TOP: String?
        let JUNGLE: String?
        let MID: String?
        let ADC: String?
        let SUPPORT: String?
        let FLEX: String?
        let BENCH: [String]?
        
        enum CodingKeys: String, CodingKey {
            case TOP, JUNGLE, MID, ADC, SUPPORT, FLEX, BENCH
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            TOP = try container.decodeIfPresent(String.self, forKey: .TOP)
            JUNGLE = try container.decodeIfPresent(String.self, forKey: .JUNGLE)
            MID = try container.decodeIfPresent(String.self, forKey: .MID)
            ADC = try container.decodeIfPresent(String.self, forKey: .ADC)
            SUPPORT = try container.decodeIfPresent(String.self, forKey: .SUPPORT)
            FLEX = try container.decodeIfPresent(String.self, forKey: .FLEX)
            BENCH = try container.decodeIfPresent([String].self, forKey: .BENCH)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case leagueId
        case totalPoints
        case weeklyPoints
        case players
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        leagueId = try container.decodeIfPresent(String.self, forKey: .leagueId)
        totalPoints = try container.decodeIfPresent(Int.self, forKey: .totalPoints) ?? 0
        
        // Handle weeklyPoints as a dictionary of AnyCodable
        if let weeklyPointsContainer = try? container.nestedContainer(keyedBy: DynamicCodingKeys.self, forKey: .weeklyPoints) {
            var tempDict = [String: AnyCodable]()
            for key in weeklyPointsContainer.allKeys {
                if let value = try? weeklyPointsContainer.decodeNil(forKey: key), value {
                    tempDict[key.stringValue] = AnyCodable(nil)
                } else if let value = try? weeklyPointsContainer.decode(Int.self, forKey: key) {
                    tempDict[key.stringValue] = AnyCodable(value)
                } else if let value = try? weeklyPointsContainer.decode(String.self, forKey: key) {
                    tempDict[key.stringValue] = AnyCodable(value)
                } else if let value = try? weeklyPointsContainer.decode(Double.self, forKey: key) {
                    tempDict[key.stringValue] = AnyCodable(value)
                } else if let value = try? weeklyPointsContainer.decode(Bool.self, forKey: key) {
                    tempDict[key.stringValue] = AnyCodable(value)
                }
                // Add more types as needed
            }
            weeklyPoints = tempDict
        } else {
            weeklyPoints = nil
        }
        
        players = try container.decodeIfPresent(PlayersPositions.self, forKey: .players)
    }
    
    // For handling dynamic keys in weeklyPoints
    struct DynamicCodingKeys: CodingKey {
        var stringValue: String
        var intValue: Int?
        
        init?(stringValue: String) {
            self.stringValue = stringValue
            self.intValue = nil
        }
        
        init?(intValue: Int) {
            self.stringValue = "\(intValue)"
            self.intValue = intValue
        }
    }
    
    // A wrapper to make Any type values Codable
    struct AnyCodable: Codable {
        let value: Any?
        
        init(_ value: Any?) {
            self.value = value
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            
            if container.decodeNil() {
                self.value = nil
            } else if let bool = try? container.decode(Bool.self) {
                self.value = bool
            } else if let int = try? container.decode(Int.self) {
                self.value = int
            } else if let double = try? container.decode(Double.self) {
                self.value = double
            } else if let string = try? container.decode(String.self) {
                self.value = string
            } else if let array = try? container.decode([AnyCodable].self) {
                self.value = array.map { $0.value }
            } else if let dictionary = try? container.decode([String: AnyCodable].self) {
                self.value = dictionary.mapValues { $0.value }
            } else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "AnyCodable cannot decode value")
            }
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            
            switch value {
            case nil:
                try container.encodeNil()
            case let bool as Bool:
                try container.encode(bool)
            case let int as Int:
                try container.encode(int)
            case let double as Double:
                try container.encode(double)
            case let string as String:
                try container.encode(string)
            case let array as [Any?]:
                try container.encode(array.map { AnyCodable($0) })
            case let dictionary as [String: Any?]:
                try container.encode(dictionary.mapValues { AnyCodable($0) })
            default:
                let context = EncodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "AnyCodable cannot encode value \(String(describing: value))"
                )
                throw EncodingError.invalidValue(value as Any, context)
            }
        }
    }
    
}
