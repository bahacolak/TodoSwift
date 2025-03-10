import SwiftUI
import SwiftData

struct MedicationsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var medications: [Medication]
    @State private var showingAddMedication = false
    @State private var searchText = ""
    
    private var filteredMedications: [Medication] {
        if searchText.isEmpty {
            return medications
        }
        return medications.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        ZStack {
            if medications.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "pills.circle")
                        .font(.system(size: 50))
                        .foregroundColor(ThemeColors.primary)
                    
                    Text("No medications yet")
                        .font(.title3)
                        .foregroundColor(ThemeColors.textPrimary)
                    
                    Button(action: { showingAddMedication = true }) {
                        Text("Add Medication")
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(ThemeColors.primary)
                            .cornerRadius(8)
                    }
                }
            } else {
                VStack {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(ThemeColors.primary)
                        TextField("Search medications...", text: $searchText)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    // Medications List
                    List {
                        ForEach(filteredMedications) { medication in
                            NavigationLink(destination: MedicationDetailView(medication: medication)) {
                                MedicationRow(medication: medication)
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    deleteMedication(medication)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
        }
        .toolbar {
            if !medications.isEmpty {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddMedication = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(ThemeColors.primary)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddMedication) {
            AddMedicationView()
        }
    }
    
    private func deleteMedication(_ medication: Medication) {
        withAnimation {
            modelContext.delete(medication)
        }
    }
}

struct MedicationRow: View {
    let medication: Medication
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(medication.name)
                    .font(.headline)
                Spacer()
                if medication.reminder {
                    Image(systemName: "bell.fill")
                        .foregroundColor(ThemeColors.primary)
                }
            }
            
            HStack {
                Label(medication.dosage, systemImage: "pills.fill")
                Spacer()
                Label(medication.frequency, systemImage: "calendar")
            }
            .font(.subheadline)
            .foregroundColor(.gray)
            
            if !medication.timeOfDay.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(medication.timeOfDay, id: \.self) { time in
                            Label(time.rawValue, systemImage: time.icon)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(ThemeColors.primary.opacity(0.1))
                                .foregroundColor(ThemeColors.primary)
                                .cornerRadius(8)
                        }
                    }
                }
            }
            
            if let stock = medication.stock {
                HStack {
                    Label("\(stock) remaining", systemImage: "number")
                        .font(.caption)
                        .foregroundColor(stock <= (medication.stockAlert ?? 5) ? .red : .gray)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    MedicationsView()
} 