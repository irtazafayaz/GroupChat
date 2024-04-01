//
//  GroupsListView.swift
//  GroupChat
//
//  Created by Irtaza Fiaz on 21/03/2024.
//

import SwiftUI

struct GroupsListView: View {
    
    @ObservedObject private var viewModel = GroupsVM()
    @EnvironmentObject var sessionManager: SessionManager
    @State private var selectedGroup: Group?
    @State private var openGroupChat: Bool = false
    
    var body: some View {
        VStack {
            
            HStack {
                Text("Groups")
                    .font(.custom(FontFamily.bold.rawValue, size: 30))
                    .foregroundColor(.black)
                Spacer()
                
                Button {
                    viewModel.showingAddGroupView.toggle()
                } label: {
                    Image(systemName: "plus.rectangle.fill.on.rectangle.fill")
                        .font(.custom(FontFamily.bold.rawValue, size: 20))
                        .foregroundColor(.black)
                }
            }
            .padding()
            .background(Color("primary-color"))
            
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
                                            AsyncImage(url: url, content: view)
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
                                                .foregroundStyle(.black)
                                                .bold()
                                            Text(group.description)
                                                .font(.custom(FontFamily.regular.rawValue, size: 16))
                                                .foregroundStyle(.gray)
                                        }
                                        .padding(.leading, 5)
                                        Spacer()
                                    }
                                    Divider()
                                        .frame(maxWidth: .infinity)
                                }
                                .padding()
                                
                            }
                        }
                    }
                }
            }
            Spacer()
            
            Button("Discover") {
                viewModel.openDiscoverGroupsView.toggle()
            }
            
        }
        .sheet(isPresented: $viewModel.showingAddGroupView) {
            AddGroupView(isPresented: $viewModel.showingAddGroupView)
        }
        .sheet(isPresented: $viewModel.openDiscoverGroupsView) {
            DiscoverGroupsView(viewModel: viewModel, isPresented: $viewModel.openDiscoverGroupsView)
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
    
    @ViewBuilder
    private func view(for phase: AsyncImagePhase) -> some View {
        switch phase {
        case .empty:
            ProgressView()
        case .success(let image):
            image
                .resizable()
        case .failure(let error):
            VStack(spacing: 16) {
                Image(systemName: "xmark.octagon.fill")
                    .foregroundColor(.red)
                Text(error.localizedDescription)
                    .multilineTextAlignment(.center)
            }
        @unknown default:
            Text("Unknown")
                .foregroundColor(.gray)
        }
    }
    
}


#Preview {
    GroupsListView()
}
