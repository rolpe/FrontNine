//
//  MainTabView.swift
//  Front Nine
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Tab = .rankings
    @State private var rankingsPath = NavigationPath()
    @State private var profilePath = NavigationPath()
    @State private var activityPath = NavigationPath()

    enum Tab: Int {
        case rankings, activity, profile
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            RankingsView(navigationPath: $rankingsPath)
                .tag(Tab.rankings)
                .tabItem {
                    Label("Rankings", systemImage: "list.number")
                }

            ActivityFeedView(navigationPath: $activityPath)
                .tag(Tab.activity)
                .tabItem {
                    Label("Activity", systemImage: "bell")
                }

            ProfileFlowView(showDismiss: false, navigationPath: $profilePath)
                .tag(Tab.profile)
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
        }
        .tint(FNColors.sage)
        .onChange(of: selectedTab) { oldTab, _ in
            switch oldTab {
            case .rankings: rankingsPath = NavigationPath()
            case .activity: activityPath = NavigationPath()
            case .profile: profilePath = NavigationPath()
            }
        }
    }
}
