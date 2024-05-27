//
//  TrendingView.swift
//  GroupChat
//
//  Created by Irtaza Fiaz on 03/04/2024.
//

import SwiftUI

struct TrendingView: View {
    
    @EnvironmentObject var sessionManager: SessionManager
    
    @State private var searchText = ""
    @Binding var selectedTab: Int
    
    @State var groupsArray: [Group] = []
    @State var ownedOrJoinedGroups: [Group] = []
    @State var notJoinedGroups: [Group] = []
    
    @State var isLoading: Bool = false
    @State var showingAddGroupView = false
    @State var openDiscoverGroupsView = false
    @State var isFetchingGroups = false
    @State var filteredGroups: [Group] = []
    
    
    var body: some View {
        VStack {
            
            HStack {
                Text("Trending Groups 🔥")
                    .font(.custom(FontFamily.bold.rawValue, size: 26))
                    .foregroundColor(.white)
                Spacer()
            }
            .frame(height: 30)
            .padding()
            .background(.pink)

            SearchBar(text: $searchText)
            
            if filteredGroups.count > 0 {
                ScrollView {
                    VStack {
                        ForEach(filteredGroups.prefix(10), id: \.id) { group in
                            VStack {
                                HStack {
                                    if let url = URL(string: group.image) {
                                        CachedAsyncImageView(url: url)
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 50, height: 50)
                                            .clipShape(Circle())
                                    } else {
                                        Color.black
                                            .frame(width: 50, height: 50)
                                    }
                                    
                                    VStack(alignment: .leading) {
                                        Text(group.name)
                                            .font(.custom(FontFamily.bold.rawValue, size: 20))
                                            .foregroundColor(.white)
                                            .bold()
                                        Text(group.description)
                                            .font(.custom(FontFamily.regular.rawValue, size: 16))
                                            .foregroundColor(.white)
                                    }
                                    Spacer()
                                    
                                    Button("Join") {
                                        if let user = sessionManager.getCurrentAuthUser() {
                                            FirebaseManager.shared.joinGroup(groupId: group.id ?? "NaN", userId: user.uid) { error  in
                                                if error == nil  {
                                                    print("Error Joining Group \(String(describing: group.id))")
                                                } else {
                                                    selectedTab = 1
                                                    print("Eror \(String(describing: error))")
                                                }
                                            }
                                        }
                                    }
                                    
                                }
                                Divider()
                                    .frame(maxWidth: .infinity)
                            }
                            .padding()
                            
                            
                        }
                    }
                }
            }
            Spacer()
                .onChange(of: searchText) {
                    filterGroups(searchText)
                }
        }
        .background(Color("app-background"))
        .onAppear {
            FirebaseManager.shared.fetchGroupsByOwner((sessionManager.getCurrentAuthUser()?.uid ?? "NaN")) { groups, error in
                if error == nil {
                    groupsArray.removeAll()
                    groupsArray = groups
                    categorizeGroups()
                }

            }
        }
    }
    
    private func categorizeGroups() {
        let uid = sessionManager.getCurrentAuthUser()?.uid ?? "NaN"
        ownedOrJoinedGroups.removeAll()
        notJoinedGroups.removeAll()
        for group in groupsArray {
            if group.owner == uid || (group.members?.contains(uid) ?? false) {
                ownedOrJoinedGroups.append(group)
            } else {
                notJoinedGroups.append(group)
            }
        }
        notJoinedGroups.sort { (group1, group2) -> Bool in
            let count1 = group1.members?.count ?? 0
            let count2 = group2.members?.count ?? 0
            return count1 > count2
        }
        filterGroups("")
    }
    
    private func filterGroups(_ searchText: String) {
        if searchText.isEmpty {
            filteredGroups = notJoinedGroups
        } else {
            filteredGroups = groupsArray.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }
    
}
