import SwiftUI
import SwiftData
import Charts

struct MedicationDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @State private var isEditing = false
    
    let medication: Medication
    
    private var stockStatus: String {
        guard let stock = medication.stock else { return "No stock information" }
        guard let alert = medication.stockAlert else { return "\(stock) remaining" }
        
        if stock <= alert {
            return "Low stock alert: \(stock) remaining"
        }
        return "\(stock) remaining"
    }
    
    private var stockColor: Color {
        guard let stock = medication.stock, let alert = medication.stockAlert else { return .gray }
        return stock <= alert ? .red : .gray
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Text(medication.name)
                        .font(.title)
                        .bold()
                    
                    HStack {
                        Label(medication.dosage, systemImage: "pills.fill")
                        Text("•")
                        Label(medication.frequency, systemImage: "calendar")
                    }
                    .foregroundColor(.gray)
                }
                .padding()
                
                // Schedule
                scheduleSection
                
                // Stock Management
                stockSection
                
                // Notes
                if let notes = medication.notes, !notes.isEmpty {
                    notesSection(notes)
                }
                
                // Statistics
                if !medication.timeOfDay.isEmpty {
                    statisticsSection
                }
                
                // Action Buttons
                actionButtons
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    showingEditSheet = true
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditMedicationView(medication: medication)
        }
        .alert("Delete Medication", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                deleteMedication()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete this medication? This action cannot be undone.")
        }
    }
    
    private var scheduleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Schedule")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Start Date:")
                    Text(medication.startDate.formatted(date: .long, time: .omitted))
                        .foregroundColor(.gray)
                }
                
                if let endDate = medication.endDate {
                    HStack {
                        Text("End Date:")
                        Text(endDate.formatted(date: .long, time: .omitted))
                            .foregroundColor(.gray)
                    }
                }
                
                if !medication.timeOfDay.isEmpty {
                    Text("Time of Day:")
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(medication.timeOfDay, id: \.self) { time in
                                Label(time.rawValue, systemImage: time.icon)
                                    .font(.subheadline)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(ThemeColors.primary.opacity(0.1))
                                    .foregroundColor(ThemeColors.primary)
                                    .cornerRadius(20)
                            }
                        }
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
    }
    
    private var stockSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Stock Management")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "number")
                    Text(stockStatus)
                        .foregroundColor(stockColor)
                }
                
                if let stock = medication.stock {
                    ProgressView(value: Double(stock), total: Double(stock * 2)) {
                        HStack {
                            Text("Stock Level")
                            Spacer()
                            Text("\(stock)/\(stock * 2)")
                        }
                        .font(.caption)
                    }
                    .tint(stockColor)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
    }
    
    private func notesSection(_ notes: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Notes")
                .font(.headline)
            
            Text(notes)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemBackground))
                .cornerRadius(12)
        }
    }
    
    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Statistics")
                .font(.headline)
            
            VStack(spacing: 16) {
                // Adherence Rate Chart
                Chart {
                    ForEach(medication.timeOfDay, id: \.self) { time in
                        BarMark(
                            x: .value("Time", time.rawValue),
                            y: .value("Adherence", Double.random(in: 0.7...1.0))
                        )
                        .foregroundStyle(ThemeColors.primary.gradient)
                    }
                }
                .frame(height: 200)
                
                // Summary Stats
                HStack {
                    StatCard(title: "Total Days", value: "30")
                    StatCard(title: "Adherence", value: "92%")
                    StatCard(title: "Remaining", value: "\(medication.stock ?? 0)")
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: {
                // Implement refill action
            }) {
                Label("Refill Medication", systemImage: "plus.circle.fill")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(ThemeColors.primary)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            
            Button(action: {
                showingDeleteAlert = true
            }) {
                Label("Delete Medication", systemImage: "trash")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
    }
    
    private func deleteMedication() {
        modelContext.delete(medication)
        dismiss()
    }
}

struct StatCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.title3)
                .bold()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(ThemeColors.primary.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    NavigationView {
        MedicationDetailView(medication: Medication(
            name: "Sample Med",
            dosage: "1 pill",
            frequency: "Daily",
            startDate: Date(),
            timeOfDay: [.morning, .evening],
            notes: "Sample notes",
            stock: 10,
            stockAlert: 5
        ))
    }
} 