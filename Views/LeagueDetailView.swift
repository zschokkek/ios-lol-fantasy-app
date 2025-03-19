import SwiftUI

struct LeagueDetailView: View {
    let leagueId: String
    @StateObject private var viewModel = LeagueDetailViewModel()
    @State private var showingCreateTeamSheet = false
    @State private var showingScheduleDraftSheet = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .yellow))
                        .scaleEffect(1.5)
                        .padding(.top, 100)
                } else if let league = viewModel.league {
                    // League header
                    VStack(spacing: 10) {
                        Text(league.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        HStack(spacing: 15) {
                            // Teams badge
                            HStack {
                                Image(systemName: "person.3.fill")
                                    .foregroundColor(.yellow)
                                Text("\(league.teams.count)/\(league.totalWeeks) Teams")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            Divider()
                                .background(Color.gray.opacity(0.5))
                                .frame(height: 20)
                            
                            // Week badge
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundColor(.yellow)
                                Text("Week \(league.currentWeek)/\(league.totalWeeks)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        // Region tags
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(league.regions, id: \.self) { region in
                                    Text(region.rawValue)
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(Color.yellow.opacity(0.2))
                                        .foregroundColor(.yellow)
                                        .cornerRadius(20)
                                }
                            }
                            .padding(.horizontal, 5)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(15)
                    
                    // Action buttons
                    HStack(spacing: 15) {
                        // Join/Create team button
                        Button(action: {
                            showingCreateTeamSheet = true
                        }) {
                            HStack {
                                Image(systemName: "person.badge.plus")
                                Text("Create Team")
                            }
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding(.horizontal, 15)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.yellow, Color.orange]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(10)
                        }
                        
                        // Schedule draft button (for admin)
                        Button(action: {
                            showingScheduleDraftSheet = true
                        }) {
                            HStack {
                                Image(systemName: "calendar.badge.clock")
                                Text("Schedule Draft")
                            }
                            .font(.headline)
                            .foregroundColor(.yellow)
                            .padding(.horizontal, 15)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .background(Color.yellow.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.yellow, lineWidth: 1)
                            )
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Teams section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Teams")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        if league.teams.isEmpty {
                            Text("No teams have joined this league yet")
                                .foregroundColor(.gray)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .center)
                        } else {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 15) {
                                ForEach(league.teams) { team in
                                    LeagueTeamCard(team: team)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(15)
                    
                    // Matchups section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Week \(league.currentWeek) Matchups")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        let currentWeekMatchups = league.schedule.filter { $0.week == league.currentWeek }
                        
                        if currentWeekMatchups.isEmpty {
                            Text("No matchups scheduled for this week")
                                .foregroundColor(.gray)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .center)
                        } else {
                            VStack(spacing: 10) {
                                ForEach(currentWeekMatchups) { matchup in
                                    MatchupCard(matchup: matchup)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(15)
                    
                    // League members section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("League Members")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        ForEach(league.members) { member in
                            HStack {
                                Image(systemName: "person.circle.fill")
                                    .foregroundColor(.yellow)
                                    .font(.title3)
                                
                                Text(member.username)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                if member.id == league.creatorId {
                                    Text("Creator")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.purple.opacity(0.2))
                                        .foregroundColor(.purple)
                                        .cornerRadius(8)
                                }
                            }
                            .padding(.vertical, 8)
                            
                            if member.id != league.members.last?.id {
                                Divider()
                                    .background(Color.gray.opacity(0.5))
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(15)
                } else {
                    // Error or league not found
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.yellow)
                        
                        Text("League Not Found")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text(viewModel.errorMessage.isEmpty ? "Could not load league data" : viewModel.errorMessage)
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(15)
                    .padding(.top, 50)
                }
            }
            .padding()
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .navigationTitle("League Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadLeague(id: leagueId)
        }
        .sheet(isPresented: $showingCreateTeamSheet) {
            CreateTeamView(leagueId: leagueId, onTeamCreated: { team in
                viewModel.loadLeague(id: leagueId)
            })
        }
        .sheet(isPresented: $showingScheduleDraftSheet) {
            ScheduleDraftView(leagueId: leagueId, onDraftScheduled: {
                viewModel.loadLeague(id: leagueId)
            })
        }
    }
}

struct LeagueTeamCard: View {
    let team: FantasyTeam
    
    var body: some View {
        NavigationLink(destination: TeamDetailView(teamId: team.id)) {
            VStack(alignment: .leading, spacing: 10) {
                Text(team.name)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text(team.owner)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(1)
                
                Divider()
                    .background(Color.gray.opacity(0.5))
                
                HStack {
                    Text("\(team.filledPositions)/6")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Text(String(format: "%.1f pts", team.totalPoints))
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.yellow)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

struct MatchupCard: View {
    let matchup: League.Matchup
    
    var body: some View {
        NavigationLink(destination: MatchupDetailView(matchup: matchup)) {
            HStack {
                // Home team
                VStack(alignment: .leading, spacing: 4) {
                    Text(matchup.homeTeam?.name ?? "Team")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(matchup.homeTeam?.owner ?? "")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // VS
                VStack {
                    Text("VS")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.yellow)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.yellow.opacity(0.1))
                        .cornerRadius(15)
                }
                
                // Away team
                VStack(alignment: .trailing, spacing: 4) {
                    Text(matchup.awayTeam?.name ?? "Team")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(matchup.awayTeam?.owner ?? "")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
        }
    }
}

// Placeholder views for sheets
struct CreateTeamView: View {
    let leagueId: String
    let onTeamCreated: (FantasyTeam) -> Void
    @Environment(\.presentationMode) var presentationMode
    @State private var teamName = ""
    @State private var isCreating = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    Text("Create a new team to join this league")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    TextField("Team Name", text: $teamName)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
                    Button(action: {
                        createTeam()
                    }) {
                        Text("Create Team")
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.yellow, Color.orange]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                    .disabled(isCreating || teamName.isEmpty)
                    .opacity(teamName.isEmpty ? 0.6 : 1.0)
                    
                    Spacer()
                }
                .padding(.top, 30)
            }
            .navigationTitle("Create Team")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.yellow)
                }
            }
        }
    }
    
    private func createTeam() {
        guard !teamName.isEmpty else {
            errorMessage = "Please enter a team name"
            return
        }
        
        isCreating = true
        errorMessage = ""
        
        // This would be an API call to create a team
        // For now, we'll simulate it with a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isCreating = false
            
            // Create a mock team for demonstration
            let team = FantasyTeam(
                id: UUID().uuidString,
                name: teamName,
                owner: "Current User",
                players: [:],
                totalPoints: 0,
                leagueId: leagueId
            )
            
            onTeamCreated(team)
            presentationMode.wrappedValue.dismiss()
        }
    }
}

struct ScheduleDraftView: View {
    let leagueId: String
    let onDraftScheduled: () -> Void
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                Text("Schedule Draft View")
                    .foregroundColor(.white)
            }
            .navigationTitle("Schedule Draft")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.yellow)
                }
            }
        }
    }
}

struct MatchupDetailView: View {
    let matchup: League.Matchup
    
    var body: some View {
        Text("Matchup Detail View")
            .foregroundColor(.white)
            .navigationTitle("Matchup Details")
    }
}

struct TeamDetailView: View {
    let teamId: String
    
    var body: some View {
        Text("Team Detail View for \(teamId)")
            .foregroundColor(.white)
            .navigationTitle("Team Details")
    }
}

class LeagueDetailViewModel: ObservableObject {
    @Published var league: League?
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    func loadLeague(id: String) {
        isLoading = true
        errorMessage = ""
        
        APIService.shared.getLeagueById(id)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    
                    if case .failure(let error) = completion {
                        self?.errorMessage = "Error: \(error.localizedDescription)"
                    }
                },
                receiveValue: { [weak self] league in
                    self?.league = league
                }
            )
            .store(in: &cancellables)
    }
}
