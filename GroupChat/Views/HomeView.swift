//
//  HomeView.swift
//  GroupChat
//
//  Created by Irtaza Fiaz on 21/03/2024.
//

import SwiftUI

struct HomeView: View {
    
    
    //MARK: - Data Members
    @State private var selectedTab: Int = 0
    @EnvironmentObject var sessionManager: SessionManager
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center) {
                TabView(selection: $selectedTab) {
                    PrivateListView()
                        .tabItem {
                            Image(systemName: "message.and.waveform.fill")
                                .renderingMode(.template)
                            Text("Chat")
                        }
                        .tag(0)
                        .toolbarBackground(.white, for: .tabBar)
                        .toolbar(.visible, for: .tabBar)
                    TrendingView(selectedTab: $selectedTab)
                        .tabItem {
                            Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                                .renderingMode(.template)
                            Text("Trending")
                        }
                        .tag(1)
                        .toolbarBackground(.white, for: .tabBar)
                        .toolbar(.visible, for: .tabBar)
                    GroupsListView()
                        .tabItem {
                            Image(systemName: "rectangle.3.group.bubble.fill")
                                .renderingMode(.template)
                            Text("Groups")
                        }
                        .tag(2)
                        .toolbarBackground(.white, for: .tabBar)
                        .toolbar(.visible, for: .tabBar)
                    ProfileView()
                        .tabItem {
                            Image(systemName: "person.crop.circle.fill")
                                .renderingMode(.template)
                            Text("Profile")
                        }
                        .tag(3)
                        .toolbarBackground(.white, for: .tabBar)
                        .toolbar(.visible, for: .tabBar)
                }
                .tint(.white)
                .toolbarBackground(.white, for: .tabBar)
                .toolbar(.visible, for: .tabBar)
            }
            .toolbarBackground(.white, for: .tabBar)
            .toolbar(.visible, for: .tabBar)
            .onAppear {
                sessionManager.fetchUserFriends()
                sessionManager.fetchUserData()
            }
            .navigationBarBackButtonHidden(true)
        }
    }
    
}

#Preview {
    HomeView()
        .environmentObject(SessionManager())
}
