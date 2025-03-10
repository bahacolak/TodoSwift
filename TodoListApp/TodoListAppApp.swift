import SwiftUI
import SwiftData

@main
struct TodoListAppApp: App {
    let container: ModelContainer
    
    init() {
        // Request notification permission
        NotificationManager.shared.requestAuthorization()
        
        do {
            let schema = Schema([
                Item.self,
                Category.self,
                Medication.self
            ])
            
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                allowsSave: true
            )
            
            let modelContainer = try ModelContainer(
                for: schema,
                configurations: modelConfiguration
            )
            
            self.container = modelContainer
        } catch {
            fatalError("Could not create container: \(error.localizedDescription)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .modelContainer(container)
        }
    }
}
