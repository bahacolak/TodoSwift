import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var showingAddCategory = false
    
    var body: some View {
        HomeView(showingAddCategory: $showingAddCategory)
            .modelContainer(for: [Category.self, Item.self])
    }
}

#Preview {
    ContentView()
}

