import Foundation

struct TrashTalk: Identifiable, Codable {
    let id: String
    let authorId: String
    let authorName: String
    let content: String
    let leagueId: String
    let timestamp: Date
    var likes: [String] // Array of user IDs who liked this trash talk
    var isEdited: Bool
    
    // Computed property to get the formatted date
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
    
    // Computed property to get the relative time (e.g., "2 hours ago")
    var relativeTime: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
    
    // Helper method to check if the current user has liked this trash talk
    func isLikedBy(userId: String) -> Bool {
        return likes.contains(userId)
    }
    
    // Helper method to get the like count
    var likeCount: Int {
        return likes.count
    }
    
    // Coding keys for JSON encoding/decoding
    enum CodingKeys: String, CodingKey {
        case id
        case authorId
        case authorName
        case content
        case leagueId
        case timestamp
        case likes
        case isEdited
    }
    
    // Custom decoder to handle date formatting
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        authorId = try container.decode(String.self, forKey: .authorId)
        authorName = try container.decode(String.self, forKey: .authorName)
        content = try container.decode(String.self, forKey: .content)
        leagueId = try container.decode(String.self, forKey: .leagueId)
        
        // Handle date decoding from ISO string
        let dateString = try container.decode(String.self, forKey: .timestamp)
        let dateFormatter = ISO8601DateFormatter()
        if let date = dateFormatter.date(from: dateString) {
            timestamp = date
        } else {
            timestamp = Date() // Fallback to current date if parsing fails
        }
        
        likes = try container.decode([String].self, forKey: .likes)
        isEdited = try container.decode(Bool.self, forKey: .isEdited)
    }
    
    // Custom encoder to handle date formatting
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(authorId, forKey: .authorId)
        try container.encode(authorName, forKey: .authorName)
        try container.encode(content, forKey: .content)
        try container.encode(leagueId, forKey: .leagueId)
        
        // Convert date to ISO string
        let dateFormatter = ISO8601DateFormatter()
        let dateString = dateFormatter.string(from: timestamp)
        try container.encode(dateString, forKey: .timestamp)
        
        try container.encode(likes, forKey: .likes)
        try container.encode(isEdited, forKey: .isEdited)
    }
    
    // Init for creating a new TrashTalk
    init(id: String, authorId: String, authorName: String, content: String, leagueId: String, timestamp: Date = Date(), likes: [String] = [], isEdited: Bool = false) {
        self.id = id
        self.authorId = authorId
        self.authorName = authorName
        self.content = content
        self.leagueId = leagueId
        self.timestamp = timestamp
        self.likes = likes
        self.isEdited = isEdited
    }
}
