//
//  Front_NineApp.swift
//  Front Nine
//
//  Created by Ron Lipkin on 2/1/26.
//

import SwiftUI
import SwiftData
import FirebaseCore

@main
struct Front_NineApp: App {
    @State private var authService = AuthService()
    @State private var syncService = RankingSyncService()
    @State private var followService = FollowService()
    @State private var photoService = ProfilePhotoService()

    init() {
        FirebaseApp.configure()

        if let serifLargeDescriptor = UIFont.systemFont(ofSize: 34, weight: .medium)
            .fontDescriptor.withDesign(.serif) {
            let appearance = UINavigationBarAppearance()
            appearance.largeTitleTextAttributes = [
                .font: UIFont(descriptor: serifLargeDescriptor, size: 34)
            ]
            if let serifInlineDescriptor = UIFont.systemFont(ofSize: 17, weight: .semibold)
                .fontDescriptor.withDesign(.serif) {
                appearance.titleTextAttributes = [
                    .font: UIFont(descriptor: serifInlineDescriptor, size: 17)
                ]
            }
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
    }

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
            MainTabView()
                .environment(authService)
                .environment(syncService)
                .environment(followService)
                .environment(photoService)
                .preferredColorScheme(.light)
                .task { authService.startListening() }
        }
        .modelContainer(sharedModelContainer)
    }
}
