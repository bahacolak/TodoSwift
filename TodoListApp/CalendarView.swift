import SwiftUI

struct CalendarView: View {
    var body: some View {
        NavigationView {
            ZStack {
                ThemeColors.background
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Image(systemName: "calendar")
                        .font(.system(size: 60))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [ThemeColors.primary, ThemeColors.accent],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text("Calendar View")
                        .font(.title)
                        .foregroundColor(ThemeColors.textPrimary)
                }
            }
            .navigationTitle("Calendar")
            .toolbarBackground(ThemeColors.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

#Preview {
    CalendarView()
} 