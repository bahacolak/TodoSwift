import SwiftUI
import SwiftData

struct CategoryDetailView: View {
    let category: Category
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddTask = false
    
    var body: some View {
        List {
            ForEach(category.items ?? []) { item in
                TaskRow(item: item)
            }
            .onDelete(perform: deleteItems)
        }
        .navigationTitle(category.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddTask = true }) {
                    Image(systemName: "plus")
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
    
    init(item: Item) {
        self.item = item
        _isCompleted = State(initialValue: item.isCompleted)
    }
    
    var body: some View {
        HStack {
            Button(action: toggleCompletion) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isCompleted ? item.category?.uiColor : Color(.systemGray4))
            }
            
            VStack(alignment: .leading) {
                Text(item.title)
                    .strikethrough(isCompleted)
                
                if let startTime = item.startTime {
                    Text(startTime.formatted(date: .omitted, time: .shortened))
                        .font(.caption)
                        .foregroundColor(Color(.secondaryLabel))
                }
            }
            
            Spacer()
            
            if item.priority != .normal {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundColor(item.priority == .high ? Color(.systemRed) : Color(.systemOrange))
            }
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
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Task Title", text: $taskTitle)
                
                DatePicker("Start Time", selection: $startTime, displayedComponents: [.date, .hourAndMinute])
                
                Picker("Priority", selection: $priority) {
                    Text("Low").tag(Item.Priority.low)
                    Text("Normal").tag(Item.Priority.normal)
                    Text("High").tag(Item.Priority.high)
                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addTask()
                        dismiss()
                    }
                    .disabled(taskTitle.isEmpty)
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