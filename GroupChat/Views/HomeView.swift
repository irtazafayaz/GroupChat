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
    @StateObject private var viewModel = GroupsVM()
    @EnvironmentObject var sessionManager: SessionManager
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center) {
                TabView(selection: $selectedTab) {
                    TrendingView(viewModel: viewModel, selectedTab: $selectedTab)
                        .tabItem {
                            Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                                .renderingMode(.template)
                            Text("Trending")
                        }
                        .tag(0)
                    GroupsListView(viewModel: viewModel)
                        .tabItem {
                            Image(systemName: "rectangle.3.group.bubble.fill")
                                .renderingMode(.template)
                            Text("Groups")
                        }
                        .tag(1)
                    ProfileView()
                        .tabItem {
                            Image(systemName: "person.crop.circle.fill")
                                .renderingMode(.template)
                            Text("Profile")
                        }
                        .tag(2)
                }
                
            }
            .onAppear {
                viewModel.fetchGroupsByOwner(sessionManager.getCurrentAuthUser()?.uid ?? "NaN")
            }
            .navigationBarBackButtonHidden(true)
        }
    }
    
}

#Preview {
    HomeView()
}
