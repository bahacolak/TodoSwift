import SwiftUI
import SwiftData

struct TagManagementView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var item: Item
    @State private var newTag = ""
    
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
                            .background(ThemeColors.surface)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                            .tint(ThemeColors.primary)
                            .foregroundColor(ThemeColors.textPrimary)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .submitLabel(.done)
                            .onSubmit(addTag)
                        
                        Button(action: addTag) {
                            Image(systemName: "plus")
                                .fontWeight(.semibold)
                                .foregroundColor(ThemeColors.background)
                                .frame(width: 42, height: 42)
                                .background(ThemeColors.primary)
                                .cornerRadius(12)
                        }
                        .disabled(newTag.isEmpty)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(item.tags, id: \.self) { tag in
                                HStack {
                                    Text("#\(tag)")
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .background(ThemeColors.surface)
                                        .cornerRadius(12)
                                    
                                    Spacer()
                                    
                                    Button(action: { removeTag(tag) }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                            .padding(8)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .background(Color.clear)
                }
            }
            .navigationTitle("Manage Tags")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(ThemeColors.primary)
                }
            }
        }
    }
    
    private func addTag() {
        let tag = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !tag.isEmpty else { return }
        
        if !item.tags.contains(tag) {
            withAnimation {
                item.tags.append(tag)
                newTag = ""
            }
        }
    }
    
    private func removeTag(_ tag: String) {
        if let index = item.tags.firstIndex(of: tag) {
            withAnimation {
                item.tags.remove(at: index)
            }
        }
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