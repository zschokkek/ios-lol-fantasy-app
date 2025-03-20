import Foundation
import Combine

class ProfileViewModel: ObservableObject {
    @Published var favoritePlayers: [Player] = []
    @Published var teamsCount: Int = 0
    @Published var leaguesCount: Int = 0
    @Published var winRate: Int = 0
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    func loadUserStats(userId: String) {
        isLoading = true
        errorMessage = nil
        
        // In a real app, you would call an API to get this data
        // For now, we'll simulate with a delay and dummy data
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            // Sample data
            self?.teamsCount = 3
            self?.leaguesCount = 2
            self?.winRate = 65
            
            // Sample favorite players
            self?.favoritePlayers = [
                Player(
                    id: "player1",
                    name: "Faker",
                    position: .MID,
                    team: "T1",
                    region: .LCK,
                    imageUrl: "https://example.com/faker.jpg",
                    fantasyPoints: 245.5,
                    stats: PlayerStats(
                        gamesPlayed: 15,
                        kills: 45,
                        deaths: 15,
                        assists: 67,
                        cs: 3500,
                        visionScore: 150
                    )
                ),
                Player(
                    id: "player2",
                    name: "Caps",
                    position: .MID,
                    team: "G2",
                    region: .LEC,
                    imageUrl: "https://example.com/caps.jpg",
                    fantasyPoints: 220.0,
                    stats: PlayerStats(
                        gamesPlayed: 14,
                        kills: 42,
                        deaths: 18,
                        assists: 50,
                        cs: 3200,
                        visionScore: 140
                    )
                )
            ]
            
            self?.isLoading = false
        }
    }
}
