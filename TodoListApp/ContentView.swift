import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @Query private var categories: [Category]
    @State private var selectedDate = Date()
    @State private var showingAddTask = false
    
    init(searchDate: Date = Date()) {
        self.selectedDate = searchDate
        _items = Query()
    }
    
    private let calendar = Calendar.current
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h a"
        return formatter
    }()
    
    // Filter tasks for selected date
    private var tasksForSelectedDate: [Item] {
        items.filter { item in
            guard let startTime = item.startTime else { return false }
            return calendar.isDate(startTime, inSameDayAs: selectedDate)
        }
        .sorted { ($0.startTime ?? Date()) < ($1.startTime ?? Date()) }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Calendar Week Strip
                    CalendarStripView(selectedDate: $selectedDate)
                        .padding(.top)
                    
                    // Scheduled Reminders
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Scheduled Reminders:")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .padding(.horizontal)
                                .padding(.top)
                            
                            TimelineView(items: tasksForSelectedDate)
                        }
                    }
                    
                    // Bottom Navigation Bar
                    BottomNavBar(showingAddTask: $showingAddTask)
                }
            }
            .navigationTitle("Today's Reminders")
            .sheet(isPresented: $showingAddTask) {
                AddTaskView(isPresented: $showingAddTask, modelContext: modelContext)
            }
        }
    }
}

struct CalendarStripView: View {
    @Binding var selectedDate: Date
    private let calendar = Calendar.current
    private let daysToShow = 7
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Button(action: { moveMonth(by: -1) }) {
                    Image(systemName: "chevron.left")
                }
                
                Text(monthYearString)
                    .font(.headline)
                
                Button(action: { moveMonth(by: 1) }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(getDays(), id: \.self) { date in
                        DayCell(date: date, isSelected: calendar.isDate(date, inSameDayAs: selectedDate))
                            .onTapGesture {
                                withAnimation {
                                    selectedDate = date
                                }
                            }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 8)
        .background(Color(uiColor: .secondarySystemBackground))
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: selectedDate)
    }
    
    private func getDays() -> [Date] {
        let today = calendar.startOfDay(for: Date())
        return (0..<daysToShow).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: today)
        }
    }
    
    private func moveMonth(by value: Int) {
        if let newDate = calendar.date(byAdding: .month, value: value, to: selectedDate) {
            selectedDate = newDate
        }
    }
}

struct DayCell: View {
    let date: Date
    let isSelected: Bool
    private let calendar = Calendar.current
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    private var dayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date).uppercased()
    }
    
    var body: some View {
        VStack {
            Text(dayName)
                .font(.caption2)
                .foregroundColor(isSelected ? .white : .secondary)
            
            Text(dayNumber)
                .font(.headline)
                .foregroundColor(isSelected ? .white : .primary)
        }
        .frame(width: 45, height: 60)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color.accentColor : Color(uiColor: .tertiarySystemBackground))
        )
    }
}

struct TimelineView: View {
    let hours = Calendar.current.generateHours()
    let items: [Item]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(hours, id: \.self) { hour in
                TimeSlot(hour: hour, items: items)
            }
        }
    }
}

struct TimeSlot: View {
    let hour: Date
    let items: [Item]
    private let calendar = Calendar.current
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h a"
        return formatter
    }()
    
    private var tasksInThisHour: [Item] {
        items.filter { item in
            guard let startTime = item.startTime else { return false }
            return calendar.component(.hour, from: startTime) == calendar.component(.hour, from: hour)
        }
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Text(timeFormatter.string(from: hour))
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 50, alignment: .leading)
            
            VStack(spacing: 8) {
                if tasksInThisHour.isEmpty {
                    Rectangle()
                        .fill(Color(uiColor: .tertiarySystemBackground))
                        .frame(height: 80)
                        .cornerRadius(12)
                } else {
                    ForEach(tasksInThisHour) { task in
                        TaskCell(task: task)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

struct TaskCell: View {
    let task: Item
    
    var body: some View {
        HStack {
            Rectangle()
                .fill(task.category?.uiColor ?? Color.accentColor)
                .frame(width: 4)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.system(.body, weight: .medium))
                
                if let startTime = task.startTime, let endTime = task.endTime {
                    Text("\(formatTime(startTime)) to \(formatTime(endTime))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            
            Spacer()
        }
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

struct BottomNavBar: View {
    @Binding var showingAddTask: Bool
    
    var body: some View {
        HStack(spacing: 40) {
            BottomNavButton(icon: "house.fill", isSelected: true)
            BottomNavButton(icon: "calendar", isSelected: false)
            
            Button(action: { showingAddTask.toggle() }) {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "plus")
                            .font(.title3)
                            .foregroundColor(.white)
                    )
            }
            
            BottomNavButton(icon: "bell", isSelected: false)
            BottomNavButton(icon: "gearshape", isSelected: false)
        }
        .padding(.vertical, 8)
        .background(
            Color(uiColor: .secondarySystemBackground)
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

struct BottomNavButton: View {
    let icon: String
    let isSelected: Bool
    
    var body: some View {
        Button(action: {}) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(isSelected ? Color.accentColor : .gray)
        }
    }
}

struct AddTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var isPresented: Bool
    @State private var taskTitle = ""
    @State private var selectedDate = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var startTime = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var endTime: Date
    @State private var selectedCategory: Category?
    let modelContext: ModelContext
    
    init(isPresented: Binding<Bool>, modelContext: ModelContext) {
        self._isPresented = isPresented
        self.modelContext = modelContext
        let defaultStartTime = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date()) ?? Date()
        let defaultEndTime = Calendar.current.date(byAdding: .hour, value: 1, to: defaultStartTime) ?? Date()
        self._startTime = State(initialValue: defaultStartTime)
        self._endTime = State(initialValue: defaultEndTime)
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("Task Title", text: $taskTitle)
                }
                
                Section {
                    DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                    DatePicker("Start Time", selection: $startTime, displayedComponents: .hourAndMinute)
                    DatePicker("End Time", selection: $endTime, displayedComponents: .hourAndMinute)
                }
                
                Section {
                    Picker("Category", selection: $selectedCategory) {
                        Text("None").tag(Optional<Category>.none)
                        ForEach(Category.allCategories(modelContext)) { category in
                            Text(category.name).tag(Optional(category))
                        }
                    }
                }
            }
            .navigationTitle("Add Task")
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
        let calendar = Calendar.current
        
        // Combine selected date with selected times
        let taskStartTime = calendar.date(bySettingHour: calendar.component(.hour, from: startTime),
                                        minute: calendar.component(.minute, from: startTime),
                                        second: 0,
                                        of: selectedDate) ?? startTime
        
        let taskEndTime = calendar.date(bySettingHour: calendar.component(.hour, from: endTime),
                                      minute: calendar.component(.minute, from: endTime),
                                      second: 0,
                                      of: selectedDate) ?? endTime
        
        let newItem = Item(
            title: taskTitle,
            isCompleted: false,
            category: selectedCategory
        )
        newItem.startTime = taskStartTime
        newItem.endTime = taskEndTime
        newItem.createdDate = taskStartTime
        modelContext.insert(newItem)
    }
}

extension Category {
    static func allCategories(_ context: ModelContext) -> [Category] {
        let descriptor = FetchDescriptor<Category>()
        return (try? context.fetch(descriptor)) ?? []
    }
}

extension Calendar {
    func generateHours() -> [Date] {
        let startOfDay = self.startOfDay(for: Date())
        return (0..<24).compactMap { hour in
            self.date(byAdding: .hour, value: hour, to: startOfDay)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Item.self, Category.self, configurations: config)
        
        let category = Category(name: "Work", color: "#FF0000")
        container.mainContext.insert(category)
        
        let calendar = Calendar.current
        let now = Date()
        
        // Morning Meeting
        let task1 = Item(
            title: "Morning Meeting",
            isCompleted: false,
            timestamp: now,
            priority: .normal,
            category: category
        )
        if let startTime = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: now),
           let endTime = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: now) {
            task1.startTime = startTime
            task1.endTime = endTime
            task1.createdDate = startTime
        }
        
        // Lunch Break
        let task2 = Item(
            title: "Lunch Break",
            isCompleted: false,
            timestamp: now,
            priority: .normal,
            category: category
        )
        if let startTime = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: now),
           let endTime = calendar.date(bySettingHour: 13, minute: 0, second: 0, of: now) {
            task2.startTime = startTime
            task2.endTime = endTime
            task2.createdDate = startTime
        }
        
        container.mainContext.insert(task1)
        container.mainContext.insert(task2)
        
        return ContentView()
            .modelContainer(container)
    }
}

