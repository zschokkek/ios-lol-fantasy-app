import SwiftUI

struct TrashTalkView: View {
    let leagueId: String
    @StateObject private var viewModel = TrashTalkViewModel()
    @State private var newMessage = ""
    @State private var isEditing = false
    @State private var editingId: String? = nil
    @State private var editingContent = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Trash Talk")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    viewModel.refreshMessages()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.yellow)
                        .font(.headline)
                }
            }
            .padding()
            .background(Color.black)
            
            // Messages list
            ScrollViewReader { scrollView in
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(viewModel.messages) { message in
                            TrashTalkMessageView(
                                message: message,
                                currentUserId: viewModel.currentUserId,
                                onLike: { viewModel.likeMessage(message) },
                                onEdit: { startEditing(message) },
                                onDelete: { viewModel.deleteMessage(message) }
                            )
                            .id(message.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: viewModel.messages) { _ in
                    if let lastId = viewModel.messages.last?.id {
                        scrollView.scrollTo(lastId, anchor: .bottom)
                    }
                }
            }
            .background(Color.black)
            
            // Input area
            VStack(spacing: 10) {
                if isEditing {
                    HStack {
                        Text("Editing message")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Button(action: {
                            cancelEditing()
                        }) {
                            Text("Cancel")
                                .font(.caption)
                                .foregroundColor(.yellow)
                        }
                    }
                    .padding(.horizontal)
                }
                
                HStack(spacing: 10) {
                    TextField(isEditing ? "Edit your message..." : "Type your trash talk...", text: isEditing ? $editingContent : $newMessage)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(25)
                        .foregroundColor(.white)
                    
                    Button(action: {
                        if isEditing {
                            viewModel.updateMessage(id: editingId!, content: editingContent)
                            cancelEditing()
                        } else {
                            viewModel.sendMessage(content: newMessage)
                            newMessage = ""
                        }
                    }) {
                        Image(systemName: isEditing ? "checkmark.circle.fill" : "paperplane.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .padding(12)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.yellow, Color.orange]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .foregroundColor(.black)
                            .clipShape(Circle())
                    }
                    .disabled(isEditing ? editingContent.isEmpty : newMessage.isEmpty)
                    .opacity(isEditing ? (editingContent.isEmpty ? 0.5 : 1.0) : (newMessage.isEmpty ? 0.5 : 1.0))
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
            }
            .background(Color.black)
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color.gray.opacity(0.3)),
                alignment: .top
            )
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .onAppear {
            viewModel.loadMessages(leagueId: leagueId)
        }
    }
    
    private func startEditing(_ message: TrashTalk) {
        isEditing = true
        editingId = message.id
        editingContent = message.content
    }
    
    private func cancelEditing() {
        isEditing = false
        editingId = nil
        editingContent = ""
    }
}

struct TrashTalkMessageView: View {
    let message: TrashTalk
    let currentUserId: String
    let onLike: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    @State private var showingOptions = false
    
    var isCurrentUser: Bool {
        return message.author == currentUserId
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Author and timestamp
            HStack {
                Text(message.authorName)
                    .font(.headline)
                    .foregroundColor(isCurrentUser ? .yellow : .white)
                
                Spacer()
                
                Text(message.relativeTime)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                if isCurrentUser {
                    Button(action: {
                        showingOptions = true
                    }) {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.gray)
                    }
                    .confirmationDialog("Message Options", isPresented: $showingOptions) {
                        Button("Edit", action: onEdit)
                        Button("Delete", role: .destructive, action: onDelete)
                        Button("Cancel", role: .cancel) {}
                    }
                }
            }
            
            // Message content
            Text(message.content)
                .font(.body)
                .foregroundColor(.white)
                .padding(.vertical, 5)
            
            // Edited indicator
            if message.isEdited {
                Text("(edited)")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .italic()
            }
            
            // Like button and count
            HStack {
                Button(action: onLike) {
                    HStack(spacing: 4) {
                        Image(systemName: message.isLikedBy(userId: currentUserId) ? "heart.fill" : "heart")
                            .foregroundColor(message.isLikedBy(userId: currentUserId) ? .yellow : .gray)
                        
                        Text("\(message.likeCount)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isCurrentUser ? Color.yellow.opacity(0.3) : Color.clear,
                            lineWidth: 1
                        )
                )
        )
    }
}

class TrashTalkViewModel: ObservableObject {
    @Published var messages: [TrashTalk] = []
    @Published var isLoading = false
    
    // In a real app, this would come from AuthManager
    let currentUserId = "user123" // Placeholder for the current user's ID
    
    private var cancellables = Set<AnyCancellable>()
    
    func loadMessages(leagueId: String) {
        isLoading = true
        
        APIService.shared.getTrashTalk(leagueId: leagueId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    
                    if case .failure(let error) = completion {
                        print("Error loading trash talk: \(error)")
                    }
                },
                receiveValue: { [weak self] messages in
                    self?.messages = messages
                }
            )
            .store(in: &cancellables)
    }
    
    func refreshMessages() {
        guard let leagueId = messages.first?.league else { return }
        loadMessages(leagueId: leagueId)
    }
    
    func sendMessage(content: String) {
        guard !content.isEmpty, let leagueId = messages.first?.league else { return }
        
        // In a real app, this would be an API call
        // For now, we'll simulate it
        
        let newMessage = TrashTalk(
            id: UUID().uuidString,
            author: currentUserId,
            authorName: "Current User",
            content: content,
            league: leagueId,
            isReply: false
        )
        
        // Simulate API call delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.messages.append(newMessage)
        }
    }
    
    func likeMessage(_ message: TrashTalk) {
        // In a real app, this would be an API call
        // For now, we'll simulate it
        
        guard let index = messages.firstIndex(where: { $0.id == message.id }) else { return }
        
        var updatedMessage = message
        
        if updatedMessage.isLikedBy(userId: currentUserId) {
            // Unlike
            updatedMessage.likes.removeAll { $0 == currentUserId }
        } else {
            // Like
            updatedMessage.likes.append(currentUserId)
        }
        
        // Update the message in the array
        messages[index] = updatedMessage
    }
    
    func updateMessage(id: String, content: String) {
        guard !content.isEmpty else { return }
        
        // In a real app, this would be an API call
        // For now, we'll simulate it
        
        guard let index = messages.firstIndex(where: { $0.id == id }) else { return }
        
        var updatedMessage = messages[index]
        updatedMessage.content = content
        
        // Update the message in the array
        messages[index] = updatedMessage
    }
    
    func deleteMessage(_ message: TrashTalk) {
        // In a real app, this would be an API call
        // For now, we'll simulate it
        
        messages.removeAll { $0.id == message.id }
    }
}
