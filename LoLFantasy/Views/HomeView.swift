import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var authManager: AuthManager
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header with user info
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Welcome back,")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                
                                Text(authManager.currentUser?.username ?? "Summoner")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                            
                            NavigationLink(destination: ProfileView()) {
                                Image(systemName: "person.crop.circle")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.yellow)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        
                        // Quick stats
                        HStack(spacing: 15) {
                            StatCard(
                                title: "Leagues",
                                value: "\(viewModel.leagueCount)",
                                icon: "trophy.fill",
                                color: .yellow
                            )
                            
                            StatCard(
                                title: "Teams",
                                value: "\(viewModel.teamCount)",
                                icon: "person.3.fill",
                                color: .orange
                            )
                        }
                        .padding(.horizontal)
                        
                        // My Leagues section
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Text("My Leagues")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                NavigationLink(destination: LeaguesView()) {
                                    Text("See All")
                                        .font(.subheadline)
                                        .foregroundColor(.yellow)
                                }
                            }
                            
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .yellow))
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding()
                            } else if viewModel.leagues.isEmpty {
                                EmptyStateView(
                                    title: "No Leagues Yet",
                                    message: "Join or create a league to get started",
                                    buttonText: "Create League",
                                    action: {
                                        // Navigate to create league
                                    }
                                )
                            } else {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 15) {
                                        ForEach(viewModel.leagues) { league in
                                            LeagueCard(league: league)
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // My Teams section
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Text("My Teams")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                NavigationLink(destination: TeamsView()) {
                                    Text("See All")
                                        .font(.subheadline)
                                        .foregroundColor(.yellow)
                                }
                            }
                            
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .yellow))
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding()
                            } else if viewModel.teams.isEmpty {
                                EmptyStateView(
                                    title: "No Teams Yet",
                                    message: "Create a team to join a league",
                                    buttonText: "Create Team",
                                    action: {
                                        // Navigate to create team
                                    }
                                )
                            } else {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 15) {
                                        ForEach(viewModel.teams) { team in
                                            TeamCard(team: team)
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Upcoming Matchups
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Upcoming Matchups")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .yellow))
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding()
                            } else if viewModel.upcomingMatchups.isEmpty {
                                Text("No upcoming matchups")
                                    .foregroundColor(.gray)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .center)
                            } else {
                                VStack(spacing: 10) {
                                    ForEach(viewModel.upcomingMatchups) { matchup in
                                        MatchupRow(matchup: matchup)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                viewModel.loadData()
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(color)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text(value)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                Spacer()
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(15)
        }
        .frame(maxWidth: .infinity)
    }
}

struct LeagueCard: View {
    let league: League
    
    var body: some View {
        NavigationLink(destination: LeagueDetailView(leagueId: league.id)) {
            VStack(alignment: .leading, spacing: 10) {
                Text(league.name)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                HStack {
                    Text("\(league.teams.count)/\(league.maxTeams) Teams")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Text("Week \(league.currentWeek)")
                        .font(.caption)
                        .foregroundColor(.yellow)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.yellow.opacity(0.2))
                        .cornerRadius(8)
                }
                
                Divider()
                    .background(Color.gray.opacity(0.5))
                
                Text("Draft: \(league.draftCompleted ? "Completed" : league.draftInProgress ? "In Progress" : "Not Started")")
                    .font(.caption)
                    .foregroundColor(league.draftCompleted ? .green : league.draftInProgress ? .yellow : .gray)
            }
            .padding()
            .frame(width: 250)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(LinearGradient(
                        gradient: Gradient(colors: [Color.yellow, Color.orange]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ), lineWidth: 2)
            )
        }
    }
}

struct TeamCard: View {
    let team: FantasyTeam
    
    var body: some View {
        NavigationLink(destination: TeamDetailView(teamId: team.id)) {
            VStack(alignment: .leading, spacing: 10) {
                Text(team.name)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text("Owner: \(team.owner)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Divider()
                    .background(Color.gray.opacity(0.5))
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Players")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Text("\(team.filledPositions)/6")
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Points")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Text("\(Int(team.totalPoints))")
                            .font(.subheadline)
                            .foregroundColor(.yellow)
                    }
                }
            }
            .padding()
            .frame(width: 200)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(15)
        }
    }
}

struct MatchupRow: View {
    let matchup: League.Matchup
    
    var body: some View {
        NavigationLink(destination: MatchupDetailView(matchup: matchup)) {
            HStack {
                VStack(alignment: .leading) {
                    Text(matchup.homeTeam?.name ?? "Team")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(matchup.homeTeam?.owner ?? "")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text("VS")
                    .font(.headline)
                    .foregroundColor(.yellow)
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(matchup.awayTeam?.name ?? "Team")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(matchup.awayTeam?.owner ?? "")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
        }
    }
}

struct EmptyStateView: View {
    let title: String
    let message: String
    let buttonText: String
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "questionmark.circle")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(.gray)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Button(action: action) {
                Text(buttonText)
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.yellow, Color.orange]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(10)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
}

class HomeViewModel: ObservableObject {
    @Published var leagues: [League] = []
    @Published var teams: [FantasyTeam] = []
    @Published var upcomingMatchups: [League.Matchup] = []
    @Published var isLoading = false
    
    var leagueCount: Int { leagues.count }
    var teamCount: Int { teams.count }
    
    private var cancellables = Set<AnyCancellable>()
    
    func loadData() {
        isLoading = true
        
        // Load leagues
        APIService.shared.getLeagues()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        print("Error loading leagues: \(error)")
                    }
                    self?.isLoading = false
                },
                receiveValue: { [weak self] leagues in
                    self?.leagues = leagues
                    self?.loadMatchups(from: leagues)
                }
            )
            .store(in: &cancellables)
        
        // Load teams
        APIService.shared.getTeams()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
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
    
    private func loadMatchups(from leagues: [League]) {
        var allMatchups: [League.Matchup] = []
        
        for league in leagues {
            let currentWeekMatchups = league.schedule.filter { $0.week == league.currentWeek && !$0.completed }
            allMatchups.append(contentsOf: currentWeekMatchups)
        }
        
        upcomingMatchups = allMatchups.sorted { $0.id < $1.id }.prefix(3).map { $0 }
    }
}
