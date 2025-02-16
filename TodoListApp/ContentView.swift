import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Item.order) private var items: [Item]
    @Query private var categories: [Category]
    @State private var newItemTitle = ""
    @State private var isEditing = false
    @State private var selectedCategory: Category?
    @State private var showingTagSheet = false
    @State private var selectedItem: Item?
    
    var body: some View {
        NavigationView {
            mainContent
        }
        .preferredColorScheme(.dark)
    }
    
    private var mainContent: some View {
        ZStack {
            ThemeColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                addTaskSection
                categoryPickerSection
                taskListSection
            }
        }
        .navigationTitle("Tasks")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
                    .foregroundColor(ThemeColors.textPrimary)
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationLink(destination: CategoryView()) {
                    Image(systemName: "folder.badge.plus")
                        .foregroundColor(ThemeColors.textPrimary)
                }
            }
        }
        .toolbarBackground(ThemeColors.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .sheet(isPresented: $showingTagSheet) {
            if let item = selectedItem {
                TagManagementView(item: item)
            }
        }
        .foregroundStyle(ThemeColors.textPrimary)
    }
    
    private var addTaskSection: some View {
        HStack(spacing: 12) {
            TextField("Add new task", text: $newItemTitle)
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
                .animation(.spring(response: 0.3), value: newItemTitle)
            
            Button(action: addItem) {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 42, height: 42)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(red: 52/255, green: 199/255, blue: 89/255), Color(red: 48/255, green: 176/255, blue: 82/255)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
            }
            .scaleEffect(newItemTitle.isEmpty ? 1 : 1.05)
            .animation(.spring(response: 0.3), value: newItemTitle.isEmpty)
        }
        .padding(.horizontal)
        .padding(.top, 12)
    }
    
    private var categoryPickerSection: some View {
        Picker("Category", selection: $selectedCategory) {
            Text("All Categories")
                .foregroundColor(ThemeColors.textPrimary)
                .tag(nil as Category?)
            ForEach(categories, id: \.id) { category in
                Text(category.name)
                    .foregroundColor(ThemeColors.textPrimary)
                    .tag(category as Category?)
            }
        }
        .pickerStyle(.menu)
        .tint(ThemeColors.textPrimary)
        .padding(.horizontal)
    }
    
    private var taskListSection: some View {
        List {
            ForEach(filteredItems) { item in
                ItemRow(item: item, toggleCompletion: {
                    toggleItemCompletion(item)
                })
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        deleteItem(item)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    
                    Button {
                        selectedItem = item
                        showingTagSheet = true
                    } label: {
                        Label("Tags", systemImage: "tag")
                    }
                    .tint(.orange)
                }
            }
            .onMove(perform: moveItems)
        }
        .scrollContentBackground(.hidden)
        .background(Color.clear)
        .listStyle(.plain)
    }
    
    private var filteredItems: [Item] {
        if let category = selectedCategory {
            return items.filter { $0.category?.id == category.id }
        }
        return items
    }
    
    private func addItem() {
        guard !newItemTitle.isEmpty else { return }
        withAnimation {
            let newOrder = items.count
            let newItem = Item(title: newItemTitle, order: newOrder, category: selectedCategory)
            modelContext.insert(newItem)
            newItemTitle = ""
        }
    }
    
    private func toggleItemCompletion(_ item: Item) {
        withAnimation {
            item.isCompleted.toggle()
        }
    }
    
    private func deleteItem(_ item: Item) {
        withAnimation {
            modelContext.delete(item)
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
        HStack(spacing: 12) {
            Button(action: toggleCompletion) {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(item.isCompleted ? ThemeColors.textPrimary.opacity(0.6) : ThemeColors.textPrimary)
                    .contentShape(Rectangle())
            }
            
            HStack(spacing: 8) {
                Text(item.title)
                    .font(.system(.body, weight: .medium))
                    .strikethrough(item.isCompleted)
                    .foregroundColor(item.isCompleted ? 
                        ThemeColors.textPrimary.opacity(0.6) : ThemeColors.textPrimary)
                    .lineLimit(1)
                
                if let category = item.category {
                    Text(category.name)
                        .font(.caption)
                        .foregroundColor(ThemeColors.textPrimary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(ThemeColors.surface)
                        .cornerRadius(6)
                }
                
                if !item.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 4) {
                            ForEach(item.tags, id: \.self) { tag in
                                Text("#\(tag)")
                                    .font(.caption)
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 2)
                                    .background(ThemeColors.surface)
                                    .foregroundColor(ThemeColors.textPrimary)
                                    .cornerRadius(4)
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: 44)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
        )
        .listRowBackground(Color.clear)
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
