import SwiftUI
import Combine

struct LeagueDetailView: View {
    let leagueId: String
    @StateObject private var viewModel = LeagueDetailViewModel()
    
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
                                Text("\(league.teams.count) Teams")
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
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(15)
                    
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
                    
                } else {
                    // Error or league not found
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.yellow)
                            .padding()
                        
                        Text("League Not Found")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("We couldn't find the league you're looking for.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                    }
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
    }
}

struct LeagueTeamCard: View {
    let team: FantasyTeam
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(team.name)
                .font(.headline)
                .foregroundColor(.white)
            
            Text("\(team.points, specifier: "%.1f") Points")
                .font(.caption)
                .foregroundColor(.yellow)
            
            Divider()
                .background(Color.gray.opacity(0.3))
            
            Text("Roster: \(team.roster.count) players")
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
        
        // This would be a call to an API to get the league details
        // For now, we'll create a mock league
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            // Create a mock league for preview purposes
            let mockLeague = League(
                id: id,
                name: "Test League",
                status: "Active",
                ownerName: "Kyle",
                teams: [],
                currentWeek: 1,
                totalWeeks: 10,
                teamCount: 0,
                maxTeams: 10,
                schedule: [],
                playerPool: [],
                regions: [.LCS, .LEC],
                creatorId: "user1",
                members: [],
                draftCompleted: false,
                draftInProgress: false,
                draftOrder: []

            )
            
            self?.league = mockLeague
            self?.isLoading = false
        }
    }
}
