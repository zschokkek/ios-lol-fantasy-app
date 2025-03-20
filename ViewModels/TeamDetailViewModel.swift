import Foundation
import Combine

class TeamDetailViewModel: ObservableObject {
    @Published var team: FantasyTeam?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    func loadTeam(id: String) {
        isLoading = true
        errorMessage = nil
        
        APIService.shared.getTeamById(id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] team in
                self?.team = team
            }
            .store(in: &cancellables)
    }
}
