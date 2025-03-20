import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var authManager: AuthManager
    
    // Sample data - in a real app, this would come from an API
    private let recentMatches = [
        Match(id: "1", team1Name: "Power Pickles", team2Name: "Toxic Turtles", date: Date(), status: .upcoming),
        Match(id: "2", team1Name: "Mental Maniacs", team2Name: "Digital Dragons", date: Date().addingTimeInterval(-86400), status: .completed),
        Match(id: "3", team1Name: "Power Pickles", team2Name: "Mental Maniacs", date: Date().addingTimeInterval(86400 * 3), status: .upcoming)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if let user = authManager.currentUser {
                        welcomeSection(user: user)
                    }
                    
                    matchupsSection
                    
                    leagueStandingsSection
                }
                .padding()
            }
            .navigationTitle("LoL Fantasy")
            .background(Color(.systemBackground))
        }
    }
    
    private func welcomeSection(user: User) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Welcome, \(user.username)!")
                .font(.title)
                .fontWeight(.bold)
                
            Text("Your fantasy teams are ready for action!")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical)
    }
    
    private var matchupsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Upcoming Matchups")
                .font(.headline)
                .fontWeight(.bold)
            
            ForEach(recentMatches) { match in
                NavigationLink(destination: MatchupDetailView(match: match)) {
                    MatchCard(match: match)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    private var leagueStandingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Leagues")
                .font(.headline)
                .fontWeight(.bold)
            
            // Sample leagues - in a real app, this would come from an API
            let sampleLeagues = [
                League(
                    id: "1", 
                    name: "Friends League", 
                    teams: [], 
                    currentWeek: 1, 
                    totalWeeks: 10, 
                    schedule: [], 
                    playerPool: [], 
                    regions: [.LCS, .LEC], 
                    creatorId: "user1", 
                    members: [], 
                    draftCompleted: false, 
                    draftInProgress: false, 
                    draftOrder: []
                ),
                League(
                    id: "2", 
                    name: "Office Showdown", 
                    teams: [], 
                    currentWeek: 2, 
                    totalWeeks: 10, 
                    schedule: [], 
                    playerPool: [], 
                    regions: [.LCK, .LPL], 
                    creatorId: "user2", 
                    members: [], 
                    draftCompleted: true, 
                    draftInProgress: false, 
                    draftOrder: []
                )
            ]
            
            ForEach(sampleLeagues) { league in
                NavigationLink(destination: LeagueDetailView(leagueId: league.id)) {
                    LeagueCard(league: league)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

struct MatchCard: View {
    let match: Match
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(match.team1Name)
                    .font(.headline)
                Text("vs")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text(match.team2Name)
                    .font(.headline)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(formattedDate(match.date))
                    .font(.caption)
                    .foregroundColor(.gray)
                
                statusView(match.status)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func statusView(_ status: Match.Status) -> some View {
        Group {
            switch status {
            case .upcoming:
                Text("Upcoming")
                    .foregroundColor(.blue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(5)
            case .live:
                Text("LIVE")
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.red.opacity(0.2))
                    .cornerRadius(5)
            case .completed:
                Text("Completed")
                    .foregroundColor(.green)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(5)
            }
        }
    }
}

struct LeagueCard: View {
    let league: League
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(league.name)
                    .font(.headline)
                
                Text("\(league.teams.count) Teams")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
}

// Preview provider for SwiftUI canvas
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AuthManager())
            .preferredColorScheme(.dark)
    }
}

// This struct would typically be in a separate file
// Adding it here temporarily for completeness
struct Match: Identifiable {
    let id: String
    let team1Name: String
    let team2Name: String
    let date: Date
    let status: Status
    
    enum Status {
        case upcoming
        case live
        case completed
    }
}

// This struct would typically be in a separate file
// Adding it here temporarily for completeness
struct League: Identifiable {
    let id: String
    let name: String
    let teams: [String]
    let currentWeek: Int
    let totalWeeks: Int
    let schedule: [String]
    let playerPool: [String]
    let regions: [Region]
    let creatorId: String
    let members: [String]
    let draftCompleted: Bool
    let draftInProgress: Bool
    let draftOrder: [String]
    
    enum Region: String, CaseIterable {
        case LCS = "LCS"
        case LEC = "LEC"
        case LCK = "LCK"
        case LPL = "LPL"
    }
}
