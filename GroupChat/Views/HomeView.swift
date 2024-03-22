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
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center) {
                TabView(selection: $selectedTab) {
                    PrivateMsgView()
                        .tabItem {
                            Image(systemName: "house.circle.fill")
                                .renderingMode(.template)
                            Text("Private Chat")
                        }
                        .tag(0)
                    GroupsListView()
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
            .navigationBarBackButtonHidden(true)
        }
    }
    
}

#Preview {
    HomeView()
}
