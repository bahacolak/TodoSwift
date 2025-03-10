import SwiftUI
import SwiftData

struct AddMedicationView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var name = ""
    @State private var dosage = ""
    @State private var frequency = "Daily"
    @State private var startDate = Date()
    @State private var endDate: Date?
    @State private var notes = ""
    @State private var reminder = true
    @State private var selectedTimes: Set<TimeOfDay> = []
    @State private var stock: String = ""
    @State private var stockAlert: String = ""
    
    let frequencies = ["Daily", "Weekly", "Monthly", "As needed"]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Basic Information") {
                    TextField("Medication Name", text: $name)
                    TextField("Dosage (e.g., 1 pill, 5ml)", text: $dosage)
                    Picker("Frequency", selection: $frequency) {
                        ForEach(frequencies, id: \.self) { frequency in
                            Text(frequency).tag(frequency)
                        }
                    }
                }
                
                Section("Schedule") {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: [.date])
                    
                    Toggle("Set End Date", isOn: Binding(
                        get: { endDate != nil },
                        set: { if $0 { endDate = Date() } else { endDate = nil } }
                    ))
                    
                    if endDate != nil {
                        DatePicker("End Date", selection: Binding(
                            get: { endDate ?? Date() },
                            set: { endDate = $0 }
                        ), displayedComponents: [.date])
                    }
                }
                
                Section("Time of Day") {
                    ForEach(TimeOfDay.allCases, id: \.self) { time in
                        Toggle(isOn: Binding(
                            get: { selectedTimes.contains(time) },
                            set: { isSelected in
                                if isSelected {
                                    selectedTimes.insert(time)
                                } else {
                                    selectedTimes.remove(time)
                                }
                            }
                        )) {
                            Label(time.rawValue, systemImage: time.icon)
                        }
                    }
                }
                
                Section("Stock Management") {
                    TextField("Current Stock", text: $stock)
                        .keyboardType(.numberPad)
                    TextField("Alert when below", text: $stockAlert)
                        .keyboardType(.numberPad)
                }
                
                Section("Additional Options") {
                    Toggle("Reminders", isOn: $reminder)
                    
                    if !notes.isEmpty || true {
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $notes)
                                .frame(height: 100)
                            if notes.isEmpty {
                                Text("Add notes...")
                                    .foregroundColor(.gray)
                                    .padding(.top, 8)
                                    .padding(.leading, 5)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add Medication")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addMedication()
                    }
                    .disabled(name.isEmpty || dosage.isEmpty)
                }
            }
        }
    }
    
    private func addMedication() {
        let medication = Medication(
            name: name,
            dosage: dosage,
            frequency: frequency,
            startDate: startDate,
            timeOfDay: Array(selectedTimes),
            notes: notes.isEmpty ? nil : notes,
            reminder: reminder,
            stock: Int(stock),
            stockAlert: Int(stockAlert)
        )
        
        modelContext.insert(medication)
        
        // Schedule notifications
        if reminder {
            NotificationManager.shared.scheduleMedicationReminder(for: medication)
        }
        if let stock = Int(stock), let alert = Int(stockAlert), stock <= alert {
            NotificationManager.shared.scheduleStockAlert(for: medication)
        }
        
        dismiss()
    }
}

#Preview {
    AddMedicationView()
} 