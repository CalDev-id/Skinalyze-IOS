//
//  SkinalyzeApp.swift
//  Skinalyze
//
//  Created by Heical Chandra on 23/09/24.
//

import SwiftUI
import SwiftData

@main
struct SkinalyzeApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Result.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    var body: some Scene {
        WindowGroup {
            NavigationStack{
                ContentView()
//                ProductUsedView()
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
