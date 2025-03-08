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
    @State private var isDataLoaded = false
    @State private var showAddTask = false
    
    var body: some View {
        NavigationStack {
            mainContent
        }
        .task {
            try? await Task.sleep(nanoseconds: 100_000_000)
            isDataLoaded = true
        }
    }
    
    private var mainContent: some View {
        ZStack {
            ThemeColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                if showAddTask {
                    addTaskSection
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                categoryPickerSection
                taskListSection
            }
            
            // Floating Action Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.spring(duration: 0.6)) {
                            showAddTask.toggle()
                        }
                    }) {
                        Image(systemName: showAddTask ? "xmark" : "plus")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [ThemeColors.primary, ThemeColors.accent],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                            .shadow(color: ThemeColors.primary.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .rotationEffect(.degrees(showAddTask ? 45 : 0))
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .navigationTitle("Tasks")
        .toolbarBackground(ThemeColors.background, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
                    .foregroundColor(ThemeColors.primary)
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationLink(destination: CategoryView()) {
                    Image(systemName: "folder.badge.plus")
                        .foregroundColor(ThemeColors.primary)
                }
            }
        }
        .sheet(isPresented: $showingTagSheet) {
            if let item = selectedItem, isDataLoaded {
                TagManagementView(item: item)
                    .onDisappear {
                        selectedItem = nil
                    }
            }
        }
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
                        .shadow(color: ThemeColors.primary.opacity(0.1), radius: 8, x: 0, y: 4)
                )
                .tint(ThemeColors.primary)
                .foregroundColor(ThemeColors.textPrimary)
                .submitLabel(.done)
                .onSubmit {
                    if !newItemTitle.isEmpty {
                        addItem()
                    }
                }
        }
        .padding(.horizontal)
        .padding(.top, 12)
    }
    
    private var categoryPickerSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                CategoryChip(name: "All", isSelected: selectedCategory == nil) {
                    withAnimation {
                        selectedCategory = nil
                    }
                }
                
                ForEach(categories) { category in
                    CategoryChip(
                        name: category.name,
                        color: category.uiColor,
                        isSelected: selectedCategory?.id == category.id
                    ) {
                        withAnimation {
                            selectedCategory = category
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var taskListSection: some View {
        List {
            ForEach(filteredItems) { item in
                ItemRow(item: item, toggleCompletion: {
                    toggleItemCompletion(item)
                })
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        withAnimation {
                            deleteItem(item)
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    
                    Button {
                        withAnimation {
                            selectedItem = nil
                            DispatchQueue.main.async {
                                selectedItem = item
                                showingTagSheet = true
                            }
                        }
                    } label: {
                        Label("Tags", systemImage: "tag")
                    }
                    .tint(ThemeColors.accent)
                }
                .listRowBackground(ThemeColors.surface)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
            }
            .onMove(perform: moveItems)
        }
        .scrollContentBackground(.hidden)
        .background(Color.clear)
        .listStyle(.plain)
        .overlay {
            if filteredItems.isEmpty {
                ContentUnavailableView(
                    label: {
                        Label(
                            selectedCategory == nil ? "No Tasks" : "No Tasks in Category",
                            systemImage: "checkmark.circle"
                        )
                    },
                    description: {
                        Text(selectedCategory == nil ? "Add a new task to get started" : "Add a task to this category")
                    }
                )
            }
        }
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
            
            if showAddTask {
                showAddTask = false
            }
        }
    }
    
    private func toggleItemCompletion(_ item: Item) {
        withAnimation(.spring(duration: 0.3)) {
            item.isCompleted.toggle()
        }
    }
    
    private func deleteItem(_ item: Item) {
        modelContext.delete(item)
    }
    
    private func moveItems(from source: IndexSet, to destination: Int) {
        var updatedItems = items.map { $0 }
        updatedItems.move(fromOffsets: source, toOffset: destination)
        
        for (index, item) in updatedItems.enumerated() {
            item.order = index
        }
    }
}

struct CategoryChip: View {
    let name: String
    var color: Color = ThemeColors.primary
    var isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(name)
                .font(.system(.subheadline, weight: .medium))
                .foregroundColor(isSelected ? .white : ThemeColors.textPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? color : ThemeColors.surface)
                )
                .overlay(
                    Capsule()
                        .stroke(color, lineWidth: isSelected ? 0 : 1)
                )
        }
    }
}

struct ItemRow: View {
    let item: Item
    let toggleCompletion: () -> Void
    @State private var offset: CGFloat = 1000
    
    var body: some View {
        HStack(spacing: 16) {
            Button(action: toggleCompletion) {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(item.isCompleted ? ThemeColors.success : ThemeColors.textSecondary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.system(.body))
                    .foregroundColor(ThemeColors.textPrimary)
                    .strikethrough(item.isCompleted)
                
                if !item.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(item.tags, id: \.self) { tag in
                                Text("#\(tag)")
                                    .font(.system(.caption, weight: .medium))
                                    .foregroundColor(ThemeColors.primary)
                            }
                        }
                    }
                }
            }
            
            Spacer()
            
            if let category = item.category {
                Circle()
                    .fill(category.uiColor)
                    .frame(width: 12, height: 12)
            }
        }
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(ThemeColors.surface)
                .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
        )
        .offset(x: offset)
        .onAppear {
            withAnimation(.spring(duration: 0.6, bounce: 0.3)) {
                offset = 0
            }
        }
    }
}

#Preview {
    do {
        let schema = Schema([Item.self, Category.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: config)
        
        // Add sample data
        let sampleCategory = Category(name: "Work", color: "#FF0000")
        container.mainContext.insert(sampleCategory)
        
        let example1 = Item(title: "Example task 1", isCompleted: false, category: sampleCategory)
        let example2 = Item(title: "Example task 2", isCompleted: true, category: sampleCategory)
        container.mainContext.insert(example1)
        container.mainContext.insert(example2)
        
        return NavigationStack {
            ContentView()
                .modelContainer(container)
        }
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}

