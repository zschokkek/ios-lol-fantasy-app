import SwiftUI
import Combine

struct TeamDetailView: View {
    let teamId: String
    @StateObject private var viewModel = TeamDetailViewModel()
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .yellow))
                    .scaleEffect(1.5)
            } else if let team = viewModel.team {
                ScrollView {
                    VStack(spacing: 25) {
                        // Team header
                        VStack(spacing: 15) {
                            Text(team.name)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            HStack {
                                Text("Owner: Kyle")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                Spacer()
                                
                                HStack {
                                    Text("W")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    
                                    Text("\(team.wins)")
                                        .font(.headline)
                                        .foregroundColor(.green)
                                    
                                    Text("-")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    
                                    Text("L")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    
                                    Text("\(team.losses)")
                                        .font(.headline)
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(15)
                        

                        // Roster
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Roster")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            ForEach(team.roster, id: \.position) { slot in
                                RosterSlotRow(slot: slot)
                            }
                            
                            Button(action: {
                                // Edit roster action
                            }) {
                                HStack {
                                    Spacer()
                                    
                                    Text("Edit Roster")
                                        .font(.headline)
                                        .foregroundColor(.black)
                                    
                                    Spacer()
                                }
                                .padding()
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
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(15)
                        
                        // Recent matchups
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Recent Matchups")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            ForEach(team.recentMatchups, id: \.id) { matchup in
                                NavigationLink(destination: MatchupDetailView(matchup: matchup)) {
                                    MatchupRow(matchup: matchup, teamId: team.id)
                                }
                            }

                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(15)
                    }
                    .padding()
                }
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.yellow)
                    
                    Text("Team Not Found")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Unable to load team information")
                        .font(.body)
                        .foregroundColor(.gray)
                }
            }
        }
        .navigationTitle("Team Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadTeam(id: teamId)
        }
    }
}

struct StatBox: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 5) {
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(color)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
    }
}

struct RosterSlotRow: View {
    let slot: FantasyTeam.RosterSlot
    
    var body: some View {
        HStack {
            Text(slot.position.rawValue)
                .font(.caption)
                .fontWeight(.semibold)
                .frame(width: 50)
                .padding(.vertical, 4)
                .background(positionColor.opacity(0.2))
                .foregroundColor(positionColor)
                .cornerRadius(4)
            
            if let player = slot.player {
                HStack {
                    // Player image
                    if let imageUrl = player.imageUrl, !imageUrl.isEmpty {
                        AsyncImage(url: URL(string: imageUrl)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Image(systemName: "person.fill")
                                .foregroundColor(.gray)
                        }
                        .frame(width: 30, height: 30)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(Circle())
                    } else {
                        Image(systemName: "person.fill")
                            .frame(width: 30, height: 30)
                            .background(Color.gray.opacity(0.2))
                            .clipShape(Circle())
                            .foregroundColor(.gray)
                    }
                    
                    Text(player.name)
                        .font(.subheadline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    HStack(spacing: 3) {
                        Text(player.position.rawValue)
                            .font(.caption2)
                            .foregroundColor(.gray)
                        
                        Text("•")
                            .font(.caption2)
                            .foregroundColor(.gray)
                        
                        Text(player.team)
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    
                    Text(String(format: "%.1f", player.fantasyPoints))
                        .font(.headline)
                        .foregroundColor(.yellow)
                        .frame(width: 50, alignment: .trailing)
                }
            } else {
                Text("Empty")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Button(action: {
                    // Add player action
                }) {
                    Text("Add Player")
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.yellow.opacity(0.2))
                        .foregroundColor(.yellow)
                        .cornerRadius(5)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(8)
    }
    
    private var positionColor: Color {
        switch slot.position {
        case .TOP:
            return .red
        case .JUNGLE:
            return .green
        case .MID:
            return .purple
        case .ADC:
            return .orange
        case .SUPPORT:
            return .blue
        case .FLEX:
            return .gray
        }
    }
}

struct MatchupRow: View {
    let matchup: League.Matchup
    let teamId: String
    
    private var isHomeTeam: Bool {
        matchup.homeTeamId == teamId
    }
    
    private var userTeamName: String {
        isHomeTeam ? (matchup.homeTeam?.name ?? "Your Team") : (matchup.awayTeam?.name ?? "Your Team")
    }
    
    private var opponentTeamName: String {
        isHomeTeam ? (matchup.awayTeam?.name ?? "Opponent") : (matchup.homeTeam?.name ?? "Opponent")
    }
    
    private var userIsWinner: Bool {
        if let winner = matchup.winner {
            return winner == teamId
        }
        return false
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Week \(matchup.week)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text(userTeamName)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            if matchup.completed {
                Image(systemName: userIsWinner ? "trophy.fill" : "xmark")
                    .foregroundColor(userIsWinner ? .yellow : .red)
                    .padding(.horizontal, 10)
            } else {
                Text("vs")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 10)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(matchup.completed ? "Final" : "Upcoming")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text(opponentTeamName)
                    .font(.headline)
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(10)
    }
}

class TeamDetailViewModel: ObservableObject {
    @Published var team: FantasyTeam?
    @Published var isLoading = false
    private var cancellables = Set<AnyCancellable>()
    
    func loadTeam(id: String) {
        isLoading = true
        
        LoLFantasyAPIService.shared.getTeamById(id)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    
                    if case .failure(let error) = completion {
                        print("Error loading team: \(error)")
                    }
                },
                receiveValue: { [weak self] team in
                    self?.team = team
                }
            )
            .store(in: &cancellables)
    }
}
