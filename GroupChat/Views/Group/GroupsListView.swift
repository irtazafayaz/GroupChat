//
//  GroupsListView.swift
//  GroupChat
//
//  Created by Irtaza Fiaz on 21/03/2024.
//

import SwiftUI

struct GroupsListView: View {
    
    @ObservedObject var viewModel: GroupsVM
    @EnvironmentObject var sessionManager: SessionManager
    @State private var selectedGroup: Group?
    @State private var openGroupChat: Bool = false
    
    var body: some View {
        VStack {
            
            HStack {
                Text("Groups")
                    .font(.custom(FontFamily.bold.rawValue, size: 30))
                    .foregroundColor(.white)
                Spacer()
                
                Button {
                    viewModel.showingAddGroupView.toggle()
                } label: {
                    Image(systemName: "plus.rectangle.fill.on.rectangle.fill")
                        .font(.custom(FontFamily.bold.rawValue, size: 20))
                        .foregroundColor(.black)
                }
            }
            .frame(height: 30)
            .padding()
            .background(.pink)
            
            if self.viewModel.ownedOrJoinedGroups.count > 0 {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(viewModel.ownedOrJoinedGroups, id: \.id) { group in
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
        .sheet(isPresented: $viewModel.showingAddGroupView) {
            AddGroupView(isPresented: $viewModel.showingAddGroupView)
        }
        .onAppear {
            viewModel.fetchGroupsByOwner(sessionManager.getCurrentAuthUser()?.uid ?? "NaN")
        }
        .navigationDestination(isPresented: $openGroupChat, destination: {
            if let selected = selectedGroup {
                GroupChatView(selectedGroup: selected)
            }
        })
    }
    
}


#Preview {
    GroupsListView(viewModel: GroupsVM())
        .environmentObject(SessionManager())
}
