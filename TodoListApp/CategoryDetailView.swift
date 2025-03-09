import SwiftUI
import SwiftData

struct CategoryDetailView: View {
    let category: Category
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddTask = false
    
    private var buttonGradient: LinearGradient {
        LinearGradient(
            colors: [ThemeColors.primary, ThemeColors.accent],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var body: some View {
        ZStack {
            ThemeColors.background
                .ignoresSafeArea()
            
            List {
                if category.items?.isEmpty ?? true {
                    Text("No tasks yet")
                        .foregroundColor(ThemeColors.textSecondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .padding(.top, 20)
                } else {
                    ForEach(category.items ?? []) { item in
                        TaskRow(item: item)
                    }
                    .onDelete(perform: deleteItems)
                }
            }
            .scrollContentBackground(.hidden)
            .listStyle(.plain)
        }
        .navigationTitle(category.name)
        .toolbarBackground(ThemeColors.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddTask = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(buttonGradient)
                }
            }
        }
        .sheet(isPresented: $showingAddTask) {
            AddTaskView(category: category)
        }
    }
    
    private func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            if let item = category.items?[index] {
                modelContext.delete(item)
            }
        }
    }
}

struct TaskRow: View {
    let item: Item
    @State private var isCompleted: Bool
    
    private var buttonGradient: LinearGradient {
        LinearGradient(
            colors: [ThemeColors.primary, ThemeColors.accent],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    init(item: Item) {
        self.item = item
        _isCompleted = State(initialValue: item.isCompleted)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    toggleCompletion()
                }
            }) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(buttonGradient)
                    .font(.system(size: 24))
                    .contentTransition(.symbolEffect(.replace))
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(item.title)
                    .strikethrough(isCompleted)
                    .foregroundColor(isCompleted ? ThemeColors.textSecondary : ThemeColors.textPrimary)
                    .font(.system(size: 17, weight: .medium))
                
                if let startTime = item.startTime {
                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                            .font(.system(size: 12))
                            .foregroundColor(ThemeColors.textSecondary)
                        Text(startTime.formatted(date: .omitted, time: .shortened))
                            .font(.system(size: 14))
                            .foregroundColor(ThemeColors.textSecondary)
                    }
                }
            }
            
            Spacer()
            
            if item.priority != .normal {
                priorityBadge
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(ThemeColors.surface)
                .shadow(
                    color: Color.black.opacity(0.08),
                    radius: 8,
                    x: 0,
                    y: 4
                )
        )
        .opacity(isCompleted ? 0.8 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isCompleted)
        .padding(.horizontal, 4)
        .padding(.vertical, 4)
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
    
    private var priorityBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "exclamationmark")
                .font(.system(size: 12, weight: .bold))
            Text(priorityText)
                .font(.system(size: 12, weight: .semibold))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [
                            item.priority.color.opacity(0.2),
                            item.priority.color.opacity(0.3)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .foregroundColor(item.priority.color)
    }
    
    private var priorityText: String {
        switch item.priority {
        case .low:
            return "Low"
        case .normal:
            return "Normal"
        case .high:
            return "High"
        }
    }
    
    private func toggleCompletion() {
        isCompleted.toggle()
        item.isCompleted = isCompleted
    }
}

struct AddTaskView: View {
    let category: Category
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var taskTitle = ""
    @State private var startTime = Date()
    @State private var priority: Item.Priority = .normal
    
    private var buttonGradient: LinearGradient {
        LinearGradient(
            colors: [ThemeColors.primary, ThemeColors.accent],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                ThemeColors.background
                    .ignoresSafeArea()
                
                Form {
                    Section {
                        TextField("Task Title", text: $taskTitle)
                            .foregroundColor(ThemeColors.textPrimary)
                    }
                    
                    Section {
                        DatePicker("Start Time", selection: $startTime, displayedComponents: [.date, .hourAndMinute])
                            .foregroundColor(ThemeColors.textPrimary)
                    }
                    
                    Section {
                        Picker("Priority", selection: $priority) {
                            Text("Low").tag(Item.Priority.low)
                            Text("Normal").tag(Item.Priority.normal)
                            Text("High").tag(Item.Priority.high)
                        }
                        .foregroundColor(ThemeColors.textPrimary)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(ThemeColors.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(buttonGradient)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addTask()
                        dismiss()
                    }
                    .disabled(taskTitle.isEmpty)
                    .foregroundStyle(taskTitle.isEmpty ? 
                        LinearGradient(colors: [.gray, .gray.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing) 
                        : buttonGradient)
                }
            }
        }
    }
    
    private func addTask() {
        let task = Item(
            title: taskTitle,
            isCompleted: false,
            timestamp: startTime,
            priority: priority
        )
        task.startTime = startTime
        task.createdDate = Date()
        
        modelContext.insert(task)
        task.category = category
        
        if category.items == nil {
            category.items = []
        }
        category.items?.append(task)
    }
} 