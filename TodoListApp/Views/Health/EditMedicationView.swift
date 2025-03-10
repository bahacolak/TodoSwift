import SwiftUI
import SwiftData

struct EditMedicationView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let medication: Medication
    
    @State private var name: String
    @State private var dosage: String
    @State private var frequency: String
    @State private var startDate: Date
    @State private var endDate: Date?
    @State private var notes: String
    @State private var reminder: Bool
    @State private var selectedTimes: Set<TimeOfDay>
    @State private var stock: String
    @State private var stockAlert: String
    
    let frequencies = ["Daily", "Weekly", "Monthly", "As needed"]
    
    init(medication: Medication) {
        self.medication = medication
        _name = State(initialValue: medication.name)
        _dosage = State(initialValue: medication.dosage)
        _frequency = State(initialValue: medication.frequency)
        _startDate = State(initialValue: medication.startDate)
        _endDate = State(initialValue: medication.endDate)
        _notes = State(initialValue: medication.notes ?? "")
        _reminder = State(initialValue: medication.reminder)
        _selectedTimes = State(initialValue: Set(medication.timeOfDay))
        _stock = State(initialValue: medication.stock?.description ?? "")
        _stockAlert = State(initialValue: medication.stockAlert?.description ?? "")
    }
    
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
            .navigationTitle("Edit Medication")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        updateMedication()
                    }
                    .disabled(name.isEmpty || dosage.isEmpty)
                }
            }
        }
    }
    
    private func updateMedication() {
        medication.name = name
        medication.dosage = dosage
        medication.frequency = frequency
        medication.startDate = startDate
        medication.endDate = endDate
        medication.notes = notes.isEmpty ? nil : notes
        medication.reminder = reminder
        medication.timeOfDay = Array(selectedTimes)
        medication.stock = Int(stock)
        medication.stockAlert = Int(stockAlert)
        
        // Update notifications
        if reminder {
            NotificationManager.shared.scheduleMedicationReminder(for: medication)
        } else {
            NotificationManager.shared.removeMedicationReminders(for: medication)
        }
        if let stock = Int(stock), let alert = Int(stockAlert), stock <= alert {
            NotificationManager.shared.scheduleStockAlert(for: medication)
        }
        
        dismiss()
    }
}

#Preview {
    EditMedicationView(medication: Medication(
        name: "Sample Med",
        dosage: "1 pill",
        frequency: "Daily",
        startDate: Date()
    ))
} 