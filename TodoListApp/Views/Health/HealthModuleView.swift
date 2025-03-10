import SwiftUI
import SwiftData

struct HealthModuleView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Tab Bar
            HStack(spacing: 0) {
                ForEach(HealthTab.allCases, id: \.self) { tab in
                    TabButton(
                        title: tab.title,
                        icon: tab.icon,
                        isSelected: selectedTab == tab.rawValue
                    ) {
                        withAnimation {
                            selectedTab = tab.rawValue
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top)
            
            // Tab Content
            TabView(selection: $selectedTab) {
                NavigationView {
                    MedicationsView()
                }
                .tag(0)
                
                AppointmentsView()
                    .tag(1)
                
                MeasurementsView()
                    .tag(2)
                
                HealthNotesView()
                    .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .navigationTitle("Health")
        .navigationBarTitleDisplayMode(.inline)
        .background(ThemeColors.background)
    }
}

// Health Tab Enum
enum HealthTab: Int, CaseIterable {
    case medications
    case appointments
    case measurements
    case notes
    
    var title: String {
        switch self {
        case .medications:
            return "Medications"
        case .appointments:
            return "Appointments"
        case .measurements:
            return "Measurements"
        case .notes:
            return "Notes"
        }
    }
    
    var icon: String {
        switch self {
        case .medications:
            return "pills"
        case .appointments:
            return "calendar.badge.clock"
        case .measurements:
            return "chart.line.uptrend.xyaxis"
        case .notes:
            return "note.text"
        }
    }
}

// Custom Tab Button
struct TabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(title)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(isSelected ? ThemeColors.primary.opacity(0.1) : Color.clear)
            .foregroundColor(isSelected ? ThemeColors.primary : .gray)
        }
        .buttonStyle(.plain)
    }
}

// Placeholder Views (will be replaced later)
struct AppointmentsView: View {
    var body: some View {
        Text("Appointments View")
    }
}

struct MeasurementsView: View {
    var body: some View {
        Text("Measurements View")
    }
}

struct HealthNotesView: View {
    var body: some View {
        Text("Health Notes View")
    }
}

#Preview {
    NavigationView {
        HealthModuleView()
    }
} 