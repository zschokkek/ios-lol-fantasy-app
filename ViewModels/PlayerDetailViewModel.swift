import Foundation
import Combine

class PlayerDetailViewModel: ObservableObject {
    @Published var player: Player?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    func loadPlayer(id: String) {
        isLoading = true
        errorMessage = nil
        
        // In a real app, you would call to an API to get player data
        // For now we'll simulate a network request with a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            // Create some mock player data
            let player = Player(
                id: id,
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
            )
            
            self?.player = player
            self?.isLoading = false
        }
    }
}
