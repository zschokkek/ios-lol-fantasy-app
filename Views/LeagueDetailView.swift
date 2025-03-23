import SwiftUI
import Combine

public struct LeagueDetailView: View {
    let leagueId: String
    @StateObject private var viewModel = LeagueDetailViewModel()

    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if viewModel.isLoading {
                    LoadingView()
                } else if let league = viewModel.league {
                    LeagueContentView(league: league)
                } else {
                    ErrorView(message: "Error")
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
    }
}

// MARK: - Subviews

// League Content View
struct LeagueContentView: View {
    let league: League

    var body: some View {
        VStack(spacing: 20) {
            LeagueHeaderView(league: league)
            TeamsSectionView(teams: league.teams ?? [])
        }
    }
}

// League Header
struct LeagueHeaderView: View {
    let league: League

    var body: some View {
        VStack(spacing: 10) {
            Text(league.name)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            HStack(spacing: 15) {
                TeamsBadge(count: league.teams?.count ?? 0)  
                Divider().frame(height: 20)
                WeekBadge(currentWeek: league.currentWeek, totalWeeks: 14)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(15)
    }
}

struct TeamsBadge: View {
    let count: Int

    var body: some View {
        HStack {
            Image(systemName: "person.3.fill")
                .foregroundColor(.yellow)
            Text("\(count) Teams")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
}

struct WeekBadge: View {
    let currentWeek: Int
    let totalWeeks: Int

    var body: some View {
        HStack {
            Image(systemName: "calendar")
                .foregroundColor(.yellow)
            Text("Week \(currentWeek)/\(totalWeeks)")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
}

// Teams Section
struct TeamsSectionView: View {
    let teams: [FantasyTeam]

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Teams")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            if teams.isEmpty {
                Text("No teams have joined this league yet")
                    .foregroundColor(.gray)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 15) {
                    ForEach(teams) { team in
                        LeagueTeamCard(team: team)
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
}

struct LeagueTeamCard: View {
    let team: FantasyTeam
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(team.name)
                .font(.headline)
                .foregroundColor(.white)
            
            Text("\(team.totalPoints , specifier: "%.1f") Points")
                .font(.caption)
                .foregroundColor(.yellow)
            
            Divider()
                .background(Color.gray.opacity(0.3))
            
            Text("Roster: 6 players")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
    }
}

class LeagueDetailViewModel: ObservableObject {
    @Published var league: League?
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    func loadLeague(id: String) {
        isLoading = true
        
    }   // add more to api service to get individual league data
}
