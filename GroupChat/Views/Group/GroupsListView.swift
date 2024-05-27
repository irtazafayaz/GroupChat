//
//  GroupsListView.swift
//  GroupChat
//
//  Created by Irtaza Fiaz on 21/03/2024.
//

import SwiftUI

struct GroupsListView: View {
    
    @EnvironmentObject var sessionManager: SessionManager
    
    @State private var selectedGroup: Group?
    
    @State private var openGroupChat: Bool = false
    @State private var showingAddGroupView = false

    @State private var groupsArray: [Group] = []
    @State private var ownedOrJoinedGroups: [Group] = []
    @State private var notJoinedGroups: [Group] = []
    @State var filteredGroups: [Group] = []
    
    
    var body: some View {
        VStack {
            
            HStack {
                Text("Groups")
                    .font(.custom(FontFamily.bold.rawValue, size: 30))
                    .foregroundColor(.white)
                Spacer()
                
                Button {
                    showingAddGroupView.toggle()
                } label: {
                    Image(systemName: "plus.rectangle.fill.on.rectangle.fill")
                        .font(.custom(FontFamily.bold.rawValue, size: 20))
                        .foregroundColor(.black)
                }
            }
            .frame(height: 30)
            .padding()
            .background(.pink)
            
            if ownedOrJoinedGroups.count > 0 {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(ownedOrJoinedGroups, id: \.id) { group in
                            Button {
                                selectedGroup = group
                                self.openGroupChat.toggle()
                            } label: {
                                VStack {
                                    HStack {
                                        if let url = URL(string: group.image) {
                                            CachedAsyncImageView(url: url)
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 50, height: 50)
                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                        } else {
                                            Color.black
                                                .frame(width: 50, height: 50)
                                        }
                                        
                                        VStack(alignment: .leading) {
                                            Text(group.name)
                                                .font(.custom(FontFamily.bold.rawValue, size: 20))
                                                .foregroundStyle(.white)
                                                .bold()
                                            Text(group.description)
                                                .font(.custom(FontFamily.regular.rawValue, size: 16))
                                                .foregroundStyle(.white)
                                        }
                                        .padding(.leading, 5)
                                        Spacer()
                                    }
                                    Divider()
                                        .background(.white)
                                        .frame(maxWidth: .infinity)
                                }
                                .padding()
                                
                            }
                        }
                    }
                }
            }
            Spacer()
            
        }
        .background(Color("app-background"))
        .sheet(isPresented: $showingAddGroupView) {
            AddGroupView(isPresented: $showingAddGroupView)
        }
        .onAppear {
            FirebaseManager.shared.fetchGroupsByOwner((sessionManager.getCurrentAuthUser()?.uid ?? "NaN")) { groups, error in
                if error == nil {
                    groupsArray.removeAll()
                    groupsArray = groups
                    categorizeGroups()
                }

            }
        }
        .navigationDestination(isPresented: $openGroupChat, destination: {
            if let selected = selectedGroup {
                GroupChatView(selectedGroup: selected)
            }
        })
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


#Preview {
    GroupsListView()
        .environmentObject(SessionManager())
}
