//
//  Front_NineApp.swift
//  Front Nine
//
//  Created by Ron Lipkin on 2/1/26.
//

import SwiftUI
import SwiftData

@main
struct Front_NineApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Course.self,
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
            RankingsView()
        }
        .modelContainer(sharedModelContainer)
    }
}
