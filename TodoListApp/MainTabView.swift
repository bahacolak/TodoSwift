import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Tasks", systemImage: "list.bullet")
                }
            
            CalendarView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
        }
        .tint(ThemeColors.primary)
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [Category.self, Item.self])
} 