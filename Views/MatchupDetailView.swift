import SwiftUI
import Foundation

// Local Match implementation to fix build errors - make it accessible
struct Match {
    let id: String
    let date: Date
    let team1Id: String
    let team2Id: String
    let team1Name: String
    let team2Name: String
    let team1Score: Double?
    let team2Score: Double?
    let completed: Bool
    let playersPoints: [String: Double]
    let winnerId: String?
    
    enum Status: String {
        case scheduled
        case inProgress
        case completed
        case canceled
    }
    
    var status: Status {
        if completed {
            return .completed
        } else if Date() > date {
            return .inProgress
        } else {
            return .scheduled
        }
    }
}

public struct MatchupDetailView: View {
    let match: Match
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Match header
                VStack(spacing: 15) {
                    Text("\(match.team1Name) vs \(match.team2Name)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(formattedDate(match.date))
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    statusView(match.status)
                        .padding(.top, 5)
                }
                .padding(.vertical)
                
                // Scores
                HStack(spacing: 15) {
                    TeamScoreView(
                        teamName: match.team1Name,
                        score: match.team1Score ?? 0,
                        isWinner: match.winnerId == match.team1Id
                    )
                    
                    Text("VS")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    TeamScoreView(
                        teamName: match.team2Name,
                        score: match.team2Score ?? 0,
                        isWinner: match.winnerId == match.team2Id
                    )
                }
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(15)
                
                // Player performances
                VStack(alignment: .leading, spacing: 15) {
                    Text("Player Performances")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    if match.playersPoints.isEmpty {
                        Text("No player data available")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ForEach(Array(match.playersPoints.keys.sorted()), id: \.self) { playerId in
                            if let points = match.playersPoints[playerId] {
                                PlayerPointsRow(
                                    playerId: playerId,
                                    points: points
                                )
                            }
                        }
                    }
                }
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(15)
            }
            .padding()
        }
        .navigationTitle("Match Details")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func statusView(_ status: Match.Status) -> some View {
        HStack {
            Circle()
                .fill(statusColor(status))
                .frame(width: 10, height: 10)
            
            Text(statusText(status))
                .font(.caption)
                .foregroundColor(statusColor(status))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(statusColor(status).opacity(0.2))
        .cornerRadius(15)
    }
    
    private func statusColor(_ status: Match.Status) -> Color {
        switch status {
        case .scheduled:
            return .blue
        case .inProgress:
            return .green
        case .completed:
            return .gray
        case .canceled:
            return .red
        }
    }
    
    private func statusText(_ status: Match.Status) -> String {
        status.rawValue.capitalized
    }
}

struct TeamScoreView: View {
    let teamName: String
    let score: Double
    let isWinner: Bool
    
    var body: some View {
        VStack(spacing: 10) {
            Text(teamName)
                .font(.headline)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text("\(Int(score))")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(isWinner ? .green : .white)
            
            if isWinner {
                Text("WINNER")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(8)
            }
        }
        .frame(width: 120, height: 120)
        .padding()
        .background(Color(UIColor.systemGray5))
        .cornerRadius(15)
    }
}

struct PlayerPointsRow: View {
    let playerId: String
    let points: Double
    
    var body: some View {
        HStack {
            // Placeholder for player avatar
            Circle()
                .fill(Color(UIColor.systemGray4))
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Player #\(playerId)")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("Position")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text("\(points, specifier: "%.1f") pts")
                .font(.headline)
                .foregroundColor(points > 15 ? .green : points < 5 ? .red : .white)
        }
        .padding()
        .background(Color(UIColor.systemGray5))
        .cornerRadius(10)
    }
}
