import SwiftUI

struct MainTabView: View {
    @State private var showingAddCategory = false
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.clear
                .edgesIgnoringSafeArea(.all)
            
            TabView(selection: $selectedTab) {
                HomeView(showingAddCategory: $showingAddCategory)
                    .tag(0)
                    .tabItem {
                        Label("Tasks", systemImage: "list.bullet")
                    }
                
                Text("")
                    .tag(1)
                
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
            
            // Custom Add Button
            Button(action: {
                showingAddCategory = true
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [ThemeColors.primary, ThemeColors.accent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .offset(y: -35)
            .edgesIgnoringSafeArea(.bottom)
        }
        .edgesIgnoringSafeArea(.bottom)
        .sheet(isPresented: $showingAddCategory) {
            AddCategoryView()
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [Category.self, Item.self])
} 