import SwiftUI

public struct HomeView: View {
    @EnvironmentObject var authManager: AuthManager

    public var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                content
            }
        } else {
            NavigationView {
                content
            }
        }
    }

    private var content: some View {
        VStack(spacing: 20) {
            Spacer()

            VStack(alignment: .center, spacing: 10) {
                Text("Welcome to Fantasy League of Legends!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text("Manage your teams, leagues, and players easily.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)

            NavigationLink(destination: LoginView()) {
                Text("Get Started")
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 12)
                    .background(Color.yellow)
                    .cornerRadius(12)
            }
            .padding(.top, 20)

            Spacer()
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .onAppear {
            print("🏠 HomeView appeared!")
        }
    }
}
