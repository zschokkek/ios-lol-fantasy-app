import Foundation

struct TrashTalk: Identifiable, Codable {
    let id: String
    let author: String // User ID
    let authorName: String
    let content: String
    let league: String // League ID
    var teamId: String?
    var teamName: String?
    var likes: [String] // Array of user IDs who liked this trash talk
    var parent: String? // Parent TrashTalk ID for replies
    var isReply: Bool
    var mentions: [String]? // Array of user IDs mentioned
    let createdAt: Date
    let updatedAt: Date
    
    // Computed property to get the formatted date
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: createdAt)
    }
    
    // Computed property to get the relative time (e.g., "2 hours ago")
    var relativeTime: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
    
    // Helper method to check if the current user has liked this trash talk
    func isLikedBy(userId: String) -> Bool {
        return likes.contains(userId)
    }
    
    // Helper method to get the like count
    var likeCount: Int {
        return likes.count
    }
    
    // Computed property to check if this trash talk has been edited
    var isEdited: Bool {
        return updatedAt > createdAt
    }
    
    // Coding keys for JSON encoding/decoding
    enum CodingKeys: String, CodingKey {
        case id
        case author
        case authorName
        case content
        case league
        case teamId
        case teamName
        case likes
        case parent
        case isReply
        case mentions
        case createdAt
        case updatedAt
    }
    
    // Custom decoder to handle date formatting
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        author = try container.decode(String.self, forKey: .author)
        authorName = try container.decode(String.self, forKey: .authorName)
        content = try container.decode(String.self, forKey: .content)
        league = try container.decode(String.self, forKey: .league)
        teamId = try container.decodeIfPresent(String.self, forKey: .teamId)
        teamName = try container.decodeIfPresent(String.self, forKey: .teamName)
        likes = try container.decode([String].self, forKey: .likes)
        parent = try container.decodeIfPresent(String.self, forKey: .parent)
        isReply = try container.decode(Bool.self, forKey: .isReply)
        mentions = try container.decodeIfPresent([String].self, forKey: .mentions)
        
        // Handle date decoding from ISO string
        let createdAtString = try container.decode(String.self, forKey: .createdAt)
        let updatedAtString = try container.decode(String.self, forKey: .updatedAt)
        
        let dateFormatter = ISO8601DateFormatter()
        if let date = dateFormatter.date(from: createdAtString) {
            createdAt = date
        } else {
            createdAt = Date() // Fallback to current date if parsing fails
        }
        
        if let date = dateFormatter.date(from: updatedAtString) {
            updatedAt = date
        } else {
            updatedAt = Date() // Fallback to current date if parsing fails
        }
    }
    
    // Custom encoder to handle date formatting
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(author, forKey: .author)
        try container.encode(authorName, forKey: .authorName)
        try container.encode(content, forKey: .content)
        try container.encode(league, forKey: .league)
        try container.encodeIfPresent(teamId, forKey: .teamId)
        try container.encodeIfPresent(teamName, forKey: .teamName)
        try container.encode(likes, forKey: .likes)
        try container.encodeIfPresent(parent, forKey: .parent)
        try container.encode(isReply, forKey: .isReply)
        try container.encodeIfPresent(mentions, forKey: .mentions)
        
        // Convert date to ISO string
        let dateFormatter = ISO8601DateFormatter()
        let createdAtString = dateFormatter.string(from: createdAt)
        let updatedAtString = dateFormatter.string(from: updatedAt)
        
        try container.encode(createdAtString, forKey: .createdAt)
        try container.encode(updatedAtString, forKey: .updatedAt)
    }
    
    // Init for creating a new TrashTalk
    init(id: String, author: String, authorName: String, content: String, league: String, 
         teamId: String? = nil, teamName: String? = nil, likes: [String] = [], 
         parent: String? = nil, isReply: Bool = false, mentions: [String]? = nil,
         createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.author = author
        self.authorName = authorName
        self.content = content
        self.league = league
        self.teamId = teamId
        self.teamName = teamName
        self.likes = likes
        self.parent = parent
        self.isReply = isReply
        self.mentions = mentions
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
