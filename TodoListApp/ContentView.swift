import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Item.order) private var items: [Item]
    @State private var newItemTitle = ""
    @State private var isEditing = false
    
    var body: some View {
        NavigationView {
            ZStack {
                ThemeColors.background
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    HStack(spacing: 12) {
                        TextField("Add new task", text: $newItemTitle)
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
                        
                        Button(action: addItem) {
                            Image(systemName: "plus")
                                .fontWeight(.semibold)
                                .foregroundColor(ThemeColors.background)
                                .frame(width: 42, height: 42)
                                .background(ThemeColors.primary)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    List {
                        ForEach(items) { item in
                            ItemRow(item: item, toggleCompletion: {
                                toggleItemCompletion(item)
                            })
                        }
                        .onDelete(perform: deleteItems)
                        .onMove(perform: moveItems)
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Tasks")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(ThemeColors.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                        .foregroundColor(ThemeColors.primary)
                }
            }
            .foregroundColor(ThemeColors.textPrimary)
        }
        .preferredColorScheme(.light)
    }
    
    private func addItem() {
        guard !newItemTitle.isEmpty else { return }
        withAnimation {
            let newOrder = items.count // Yeni öğe için sıra numarası
            let newItem = Item(title: newItemTitle, order: newOrder)
            modelContext.insert(newItem)
            newItemTitle = ""
        }
    }
    
    private func toggleItemCompletion(_ item: Item) {
        withAnimation {
            item.isCompleted.toggle()
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
    
    private func moveItems(from source: IndexSet, to destination: Int) {
        var updatedItems = items.map { $0 }
        updatedItems.move(fromOffsets: source, toOffset: destination)
        
        for (index, item) in updatedItems.enumerated() {
            item.order = index
        }
    }
}

struct ItemRow: View {
    let item: Item
    let toggleCompletion: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Button(action: toggleCompletion) {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(item.isCompleted ? ThemeColors.success : ThemeColors.primary)
            }
            
            Text(item.title)
                .font(.system(.body, weight: .medium))
                .strikethrough(item.isCompleted)
                .foregroundColor(item.isCompleted ? 
                    ThemeColors.secondary.opacity(0.6) : ThemeColors.textPrimary)
        }
        .padding(.vertical, 8)
        .listRowBackground(ThemeColors.surface)
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Item.self, configurations: config)
        
        let example1 = Item(title: "Example task 1", isCompleted: false)
        let example2 = Item(title: "Example task 2", isCompleted: true)
        container.mainContext.insert(example1)
        container.mainContext.insert(example2)
        
        return ContentView()
            .modelContainer(container)
    } catch {
        return Text("Failed to load preview: \(error.localizedDescription)")
    }
}
