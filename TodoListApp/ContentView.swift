import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        HomeView()
            .modelContainer(for: [Category.self, Item.self])
    }
}

#Preview {
    ContentView()
}

