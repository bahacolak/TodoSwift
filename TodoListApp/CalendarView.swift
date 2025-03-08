import SwiftUI

struct CalendarView: View {
    var body: some View {
        NavigationView {
            ZStack {
                ThemeColors.background
                    .ignoresSafeArea()
                
                Text("Calendar View")
                    .font(.title)
                    .foregroundColor(ThemeColors.textPrimary)
            }
            .navigationTitle("Calendar")
        }
    }
}

#Preview {
    CalendarView()
} 