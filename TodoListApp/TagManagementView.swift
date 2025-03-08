import SwiftUI
import SwiftData

struct TagManagementView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var item: Item
    @State private var newTag = ""
    @State private var isLoading = true
    
    var body: some View {
        NavigationView {
            ZStack {
                ThemeColors.background
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    HStack(spacing: 12) {
                        TextField("Add new tag", text: $newTag)
                            .textFieldStyle(.plain)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(ThemeColors.surface)
                                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(ThemeColors.primary.opacity(0.1), lineWidth: 1)
                                    )
                            )
                            .tint(ThemeColors.primary)
                            .foregroundColor(ThemeColors.textPrimary)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .submitLabel(.done)
                            .onSubmit(addTag)
                        
                        Button(action: addTag) {
                            Image(systemName: "plus")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 42, height: 42)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color(red: 59/255, green: 130/255, blue: 246/255), Color(red: 37/255, green: 99/255, blue: 235/255)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                        }
                        .disabled(newTag.isEmpty)
                        .scaleEffect(newTag.isEmpty ? 1 : 1.05)
                        .animation(.spring(response: 0.3), value: newTag.isEmpty)
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)
                    
                    if isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        List {
                            ForEach(item.tags, id: \.self) { tag in
                                TagRowView(tag: tag, onDelete: { removeTag(tag) })
                            }
                            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: item.tags)
                        }
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .listStyle(.plain)
                    }
                }
            }
            .navigationTitle("Manage Tags")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(ThemeColors.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .foregroundColor(.white)
            .tint(.white)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(ThemeColors.primary)
                }
            }
            .task {
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
                isLoading = false
            }
        }
    }
    
    private func addTag() {
        let tag = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !tag.isEmpty else { return }
        
        if !item.tags.contains(tag) {
            item.tags.append(tag)
            newTag = ""
        }
    }
    
    private func removeTag(_ tag: String) {
        if let index = item.tags.firstIndex(of: tag) {
            item.tags.remove(at: index)
        }
    }
}

// Separate view for better performance
struct TagRowView: View {
    let tag: String
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Text("#\(tag)")
                .font(.system(.body, weight: .medium))
                .foregroundColor(ThemeColors.textPrimary)
                .lineLimit(1)
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .padding(8)
            }
        }
        .frame(height: 44)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(ThemeColors.surface)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
        .transition(.opacity.combined(with: .move(edge: .trailing)))
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Item.self, configurations: config)
        let example = Item(title: "Example task", tags: ["important", "work"])
        
        return TagManagementView(item: example)
            .modelContainer(container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
} 