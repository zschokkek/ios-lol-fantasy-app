import SwiftUI
import Combine

public struct TeamsView: View {
    @StateObject private var viewModel = TeamsViewModel()
    @State private var searchText = ""
    @State private var showingCreateTeam = false
    
    public var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .padding(.leading, 8)
                    
                    TextField("Search teams", text: $searchText)
                        .foregroundColor(.white)
                        .padding(8)
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                        .padding(.trailing, 8)
                    }
                }
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal)
                
                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .yellow))
                        .scaleEffect(1.5)
                    Spacer()
                } else if viewModel.teams.isEmpty {
                    Spacer()
                    VStack(spacing: 20) {
                        Image(systemName: "person.3.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.yellow)
                        
                        Text("No Teams Found")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Create a team to get started")
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        
                        Button(action: {
                            showingCreateTeam = true
                        }) {
                            Text("Create Team")
                                .font(.headline)
                                .foregroundColor(.black)
                                .padding()
                                .frame(maxWidth: 200)
                                .background(Color.yellow)
                                .cornerRadius(10)
                        }
                        .padding(.top, 10)
                    }
                    .padding()
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 15) {
                            ForEach(filteredTeams, id: \.id) { team in
                                NavigationLink(destination: TeamDetailView(teamId: team.id)) {
                                    TeamCard(team: team)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("My Teams")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingCreateTeam = true
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.yellow)
                    }
                }
            }
            .sheet(isPresented: $showingCreateTeam) {
                CreateTeamView()
            }
            .onAppear {
                if viewModel.teams.isEmpty {
                    viewModel.loadTeams()
                }
            }
        }
    }
    
    private var filteredTeams: [FantasyTeam] {
        if searchText.isEmpty {
            return viewModel.teams
        } else {
            return viewModel.teams.filter { team in
                team.name.lowercased().contains(searchText.lowercased())
            }
        }
    }
}

struct TeamCard: View {
    let team: FantasyTeam

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            headerView
            rosterPreview
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
    }

    // Extracted Header
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(team.name)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("League: \(team.name)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            scoreView
        }
    }

    // Extracted Score Section
    private var scoreView: some View {
        HStack(spacing: 2) {
            Text("5")
                .font(.headline)
                .foregroundColor(.green)
            
            Text("-")
                .font(.headline)
                .foregroundColor(.gray)
            
            Text("4")
                .font(.headline)
                .foregroundColor(.red)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(15)
    }

    // Extracted Roster Preview
    private var rosterPreview: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Key Players")
                .font(.caption)
                .foregroundColor(.gray)
            
//            HStack {
//                ForEach(team.players, id: \.id) { player in
//                    VStack(spacing: 4) {
//                        Text(player.name.split(separator: " ").last ?? "")
//                            .font(.caption)
//                            .lineLimit(1)
//                            .foregroundColor(.white)
//                        
//                        Text(player.position.rawValue)
//                            .font(.caption2)
//                            .foregroundColor(.gray)
//                    }
//                    .frame(maxWidth: .infinity)
//                }
//            }
        }
        .padding(8)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(5)
    }

}
struct CreateTeamView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var teamName = ""
    @State private var selectedLeagueId: String?
    @State private var availableLeagues: [League] = []
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        TeamNameInput(teamName: $teamName)
                        LeagueSelectionView(
                            availableLeagues: availableLeagues,
                            selectedLeagueId: $selectedLeagueId
                        )
                        CreateTeamButton(
                            teamName: teamName,
                            selectedLeagueId: selectedLeagueId,
                            isLoading: isLoading,
                            createTeam: createTeam
                        )
                    }
                    .padding()
                }
            }
            .navigationTitle("Create New Team")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.yellow)
                }
            }
            .onAppear {
                loadAvailableLeagues()
            }
        }
    }
}

// MARK: - Team Name Input
struct TeamNameInput: View {
    @Binding var teamName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Team Name")
                .font(.headline)
                .foregroundColor(.gray)
            
            TextField("Enter team name", text: $teamName)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .foregroundColor(.white)
        }
    }
}

// MARK: - League Selection
struct LeagueSelectionView: View {
    let availableLeagues: [League]
    @Binding var selectedLeagueId: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Select League")
                .font(.headline)
                .foregroundColor(.gray)
            
            if availableLeagues.isEmpty {
                Text("No available leagues found")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
            } else {
                ForEach(availableLeagues, id: \.id) { league in
                    LeagueCard(league: league)
                }
            }
        }
    }
}


// MARK: - Create Team Button
struct CreateTeamButton: View {
    let teamName: String
    let selectedLeagueId: String?
    let isLoading: Bool
    let createTeam: () -> Void

    var body: some View {
        Button(action: createTeam) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                } else {
                    Text("Create Team")
                        .font(.headline)
                        .foregroundColor(.black)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.yellow)
            .cornerRadius(10)
        }
        .disabled(teamName.isEmpty || selectedLeagueId == nil || isLoading)
        .padding(.top, 10)
    }
}

// MARK: - Functions
extension CreateTeamView {
    private func loadAvailableLeagues() {
        // In a real app, this would load leagues from the API
        // For now, we'll simulate with dummy data
    }
    
    private func createTeam() {
        isLoading = true
        
        // Simulate API call with delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            presentationMode.wrappedValue.dismiss()
        }
    }
}

class TeamsViewModel: ObservableObject {
    @Published var teams: [FantasyTeam] = []
    @Published var isLoading = false
    private var cancellables = Set<AnyCancellable>()
    
    func loadTeams() {
        isLoading = true
        // Find userID later
        LoLFantasyAPIService.shared.getUserTeams()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    
                    if case .failure(let error) = completion {
                        print("Error loading teams: \(error)")
                    }
                },
                receiveValue: { [weak self] teams in
                    self?.teams = teams
                }
            )
            .store(in: &cancellables)
    }
}
