import SwiftUI
import Combine
import Foundation

public struct HomeView: View {
    @StateObject private var authManager = AuthManager()
    @StateObject private var viewModel = HomeViewModel()
    
    public var body: some View {
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
                            HomeStatCard(
                                title: "Leagues",
                                value: "\(viewModel.leaguesCount)",
                                icon: "trophy.fill",
                                color: .yellow
                            )
                            
                            HomeStatCard(
                                title: "Teams",
                                value: "\(viewModel.teamsCount)",
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
                                            HomeLeagueCard(league: league)
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
                                            HomeTeamCard(team: team)
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
                            } else if viewModel.leagues.isEmpty {
                                Text("No upcoming matchups")
                                    .foregroundColor(.gray)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .center)
                            } else {
                                VStack(spacing: 10) {
                                    ForEach(viewModel.leagues) { league in
                                        ForEach(league.schedule.filter { $0.week == league.currentWeek }.prefix(2)) { matchup in
                                            HomeMatchupRow(matchup: matchup)
                                        }
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

struct HomeStatCard: View {
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
            .padding(.horizontal)
            .padding(.vertical, 15)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.systemGray6))
        )
    }
}

struct HomeLeagueCard: View {
    let league: League
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(league.name)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                NavigationLink(destination: LeagueDetailView(leagueId: league.id)) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(league.teams.count) Teams")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text("Week \(league.currentWeek)/\(league.totalWeeks)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                if league.draftCompleted {
                    Text("Season In Progress")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.2))
                        .foregroundColor(.green)
                        .cornerRadius(4)
                } else {
                    Text("Draft Pending")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.2))
                        .foregroundColor(.orange)
                        .cornerRadius(4)
                }
            }
            
            Divider()
                .background(Color.gray.opacity(0.3))
            
            Text("Upcoming Matchups")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            ForEach(league.schedule.filter { $0.week == league.currentWeek }.prefix(2)) { matchup in
                HomeMatchupRow(matchup: matchup)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.systemGray6))
        )
    }
}

struct HomeTeamCard: View {
    let team: FantasyTeam
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(team.name)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                NavigationLink(destination: TeamDetailView(teamId: team.id)) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("League: League Name")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    HStack(spacing: 2) {
                        Text("\(Int(team.points))")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.yellow)
                        
                        Text("pts")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                Text("Rank: 2nd")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Divider()
                .background(Color.gray.opacity(0.3))
            
            Text("Roster Filled: \(calculateFilledPositions(team))/5")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            // Roster preview
            HStack(spacing: 15) {
                ForEach(Player.Position.allCases, id: \.self) { position in
                    ZStack {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 24, height: 24)
                        
                        if let player = getPlayer(for: position, in: team) {
                            Text(String(player.name.prefix(1)))
                                .font(.caption)
                                .foregroundColor(.white)
                        } else {
                            Text("?")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.systemGray6))
        )
    }
    
    private func calculateFilledPositions(_ team: FantasyTeam) -> Int {
        return team.roster.filter { $0.player != nil }.count
    }
    
    private func getPlayer(for position: Player.Position, in team: FantasyTeam) -> Player? {
        return team.roster.first(where: { $0.position == position })?.player
    }
}

struct HomeMatchupRow: View {
    let matchup: League.Matchup
    
    var body: some View {
        NavigationLink(destination: MatchupDetailView(match: convertToMatch(matchup))) {
            HStack {
                Text(matchup.homeTeam?.name ?? "Team 1")
                    .font(.subheadline)
                    .foregroundColor(.white)
                
                Spacer()
                
                if matchup.completed {
                    Text("W")
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(matchup.winner == matchup.homeTeamId ? Color.green : Color.clear)
                        .foregroundColor(matchup.winner == matchup.homeTeamId ? .white : .clear)
                        .cornerRadius(4)
                }
                
                Text("vs")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 10)
                
                if matchup.completed {
                    Text("W")
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(matchup.winner == matchup.awayTeamId ? Color.green : Color.clear)
                        .foregroundColor(matchup.winner == matchup.awayTeamId ? .white : .clear)
                        .cornerRadius(4)
                }
                
                Spacer()
                
                Text(matchup.awayTeam?.name ?? "Team 2")
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
            .padding(.vertical, 8)
        }
    }
    
    private func convertToMatch(_ matchup: League.Matchup) -> Match {
        Match(
            id: matchup.id,
            date: Date(),  // Current date or get from matchup
            team1Id: matchup.homeTeamId ?? "",
            team2Id: matchup.awayTeamId ?? "",
            team1Name: matchup.homeTeam?.name ?? "Team 1",
            team2Name: matchup.awayTeam?.name ?? "Team 2",
            team1Score: 0,  // Or get from matchup
            team2Score: 0,  // Or get from matchup
            completed: matchup.completed,
            playersPoints: [:],  // Empty dictionary
            winnerId: matchup.winner
        )
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
    @Published var isLoading = false
    @Published var leaguesCount: Int = 0
    @Published var teamsCount: Int = 0
    @Published var winRate: Int = 0
    
    func loadData() {
        isLoading = true
        
        // In a real app, you would load data from the API
        // For testing, we'll create some dummy data
        
        // Mock leagues data
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            // Set the counts
            self?.leaguesCount = 2
            self?.teamsCount = 3
            self?.winRate = 65
            
            self?.isLoading = false
        }
    }
}
