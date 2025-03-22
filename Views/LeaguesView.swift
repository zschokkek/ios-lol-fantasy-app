import SwiftUI
import Combine

public struct LeaguesView: View {
    @StateObject private var viewModel = LeaguesViewModel()
    @State private var showingCreateLeague = false
    @State private var searchText = ""
    
    public var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .padding(.leading, 8)
                    
                    TextField("Search leagues", text: $searchText)
                        .foregroundColor(.white)
                        .padding(8)
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                        .padding(.trailing, 8)
                    }
                }
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal)
                
                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .yellow))
                        .scaleEffect(1.5)
                    Spacer()
                } else if viewModel.leagues.isEmpty {
                    Spacer()
                    VStack(spacing: 20) {
                        Image(systemName: "trophy.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.yellow)
                        
                        Text("No Leagues Found")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Join or create a league to get started")
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        
                        Button(action: {
                            showingCreateLeague = true
                        }) {
                            Text("Create League")
                                .font(.headline)
                                .foregroundColor(.black)
                                .padding()
                                .frame(maxWidth: 200)
                                .background(Color.yellow)
                                .cornerRadius(10)
                        }
                        .padding(.top, 10)
                    }
                    .padding()
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 15) {
                            ForEach(filteredLeagues, id: \.id) { league in
                                NavigationLink(destination: LeagueDetailView(leagueId: league.id)) {
                                    LeagueCard(league: league)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Leagues")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingCreateLeague = true
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.yellow)
                    }
                }
            }
            .sheet(isPresented: $showingCreateLeague) {
                CreateLeagueView()
            }
            .onAppear {
                if viewModel.leagues.isEmpty {
                    viewModel.loadLeagues()
                }
            }
        }
    }
    
    private var filteredLeagues: [League] {
        if searchText.isEmpty {
            return viewModel.leagues
        } else {
            return viewModel.leagues.filter { league in
                league.name.lowercased().contains(searchText.lowercased())
            }
        }
    }
}

struct LeagueCard: View {
    let league: League
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(league.name)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Created by \(league.ownerName)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "trophy.fill")
                    .foregroundColor(.yellow)
                    .font(.title2)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Teams")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text("\(league.teamCount)/\(league.maxTeams)")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current Week")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text("\(league.currentWeek)")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Status")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text(league.status)
                        .font(.headline)
                        .foregroundColor(statusColor(for: league.status))
                }
            }
            
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
    
    private func statusColor(for status: String) -> Color {
        switch status.lowercased() {
        case "active":
            return .green
        case "pending":
            return .yellow
        case "completed":
            return .gray
        case "draft":
            return .blue
        default:
            return .white
        }
    }
}

struct CreateLeagueView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var leagueName = ""
    @State private var maxTeams = 8
    @State private var isPublic = true
    @State private var description = ""
    @State private var draftDate = Date().addingTimeInterval(86400 * 7) // One week from now
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("League Name")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            TextField("Enter league name", text: $leagueName)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Max Teams")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            Picker("Max Teams", selection: $maxTeams) {
                                ForEach([4, 6, 8, 10, 12], id: \.self) { num in
                                    Text("\(num)").tag(num)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Privacy")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            Toggle("Public League", isOn: $isPublic)
                                .toggleStyle(SwitchToggleStyle(tint: .yellow))
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            TextEditor(text: $description)
                                .frame(minHeight: 100)
                                .padding(4)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Draft Date")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            DatePicker("Select a date", selection: $draftDate, displayedComponents: [.date, .hourAndMinute])
                                .datePickerStyle(GraphicalDatePickerStyle())
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                                .accentColor(.yellow)
                        }
                        
                        Button(action: {
                            createLeague()
                        }) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                } else {
                                    Text("Create League")
                                        .font(.headline)
                                        .foregroundColor(.black)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.yellow)
                            .cornerRadius(10)
                        }
                        .disabled(leagueName.isEmpty || isLoading)
                        .padding(.top, 10)
                    }
                    .padding()
                }
            }
            .navigationTitle("Create New League")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.yellow)
                }
            }
        }
    }
    
    private func createLeague() {
        isLoading = true
        
        // Simulate API call with delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            presentationMode.wrappedValue.dismiss()
        }
    }
}

class LeaguesViewModel: ObservableObject {
    @Published var leagues: [League] = []
    @Published var isLoading = false
    private var cancellables = Set<AnyCancellable>()
    
    func loadLeagues() {
        isLoading = true
        
        LoLFantasyAPIService.shared.getLeagues()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    
                    if case .failure(let error) = completion {
                        print("Error loading leagues: \(error)")
                    }
                },
                receiveValue: { [weak self] leagues in
                    self?.leagues = leagues
                }
            )
            .store(in: &cancellables)
    }
}
