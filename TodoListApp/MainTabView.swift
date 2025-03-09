import SwiftUI

struct MainTabView: View {
    @State private var showingAddCategory = false
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeView(showingAddCategory: $showingAddCategory)
                    .tag(0)
                    .tabItem {
                        Label("Tasks", systemImage: "list.bullet")
                    }
                
                Text("")
                    .tag(1)
                    .tabItem {
                        Image(systemName: "plus.circle.fill")
                            .environment(\.symbolVariants, .fill)
                            .font(.system(size: 44))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [ThemeColors.primary, ThemeColors.accent],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                
                CalendarView()
                    .tag(2)
                    .tabItem {
                        Label("Calendar", systemImage: "calendar")
                    }
            }
            .tint(ThemeColors.primary)
            .onAppear {
                // Customize TabBar appearance
                let appearance = UITabBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = UIColor.systemBackground
                
                // Apply gradient to selected items
                appearance.stackedLayoutAppearance.selected.iconColor = UIColor(ThemeColors.primary)
                appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                    .foregroundColor: UIColor(ThemeColors.primary)
                ]
                
                // Normal state
                appearance.stackedLayoutAppearance.normal.iconColor = UIColor.systemGray
                appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                    .foregroundColor: UIColor.systemGray
                ]
                
                UITabBar.appearance().standardAppearance = appearance
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
        }
        .sheet(isPresented: $showingAddCategory) {
            AddCategoryView()
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            if newValue == 1 {
                // Middle tab selected
                showingAddCategory = true
                // Reset back to the first tab
                selectedTab = 0
            }
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [Category.self, Item.self])
} 