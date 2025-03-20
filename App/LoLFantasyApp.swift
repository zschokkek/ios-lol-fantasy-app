import SwiftUI

@main
struct LoLFantasyApp: App {
    @StateObject private var authManager = AuthManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                .preferredColorScheme(.dark)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject private var authManager: AuthManager
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                TabView {
                    HomeView()
                        .tabItem {
                            Label("Home", systemImage: "house.fill")
                        }
                    
                    PlayersView()
                        .tabItem {
                            Label("Players", systemImage: "person.3.fill")
                        }
                    
                    LeaguesView()
                        .tabItem {
                            Label("Leagues", systemImage: "trophy.fill")
                        }
                    
                    TeamsView()
                        .tabItem {
                            Label("Teams", systemImage: "shield.fill")
                        }
                    
                    ProfileView()
                        .tabItem {
                            Label("Profile", systemImage: "person.crop.circle.fill")
                        }
                }
                .accentColor(.yellow)
            } else {
                LoginView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthManager())
            .preferredColorScheme(.dark)
    }
}
