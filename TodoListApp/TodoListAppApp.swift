//
//  TodoListAppApp.swift
//  TodoListApp
//
//  Created by Bahadır Çolak on 14.02.2025.
//

import SwiftUI
import SwiftData

@main
struct TodoListAppApp: App {
    let container: ModelContainer
    
    init() {
        do {
            let schema = Schema([
                Item.self,
                Category.self
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
            ContentView()
                .modelContainer(container)
        }
    }
}
