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
                        .font(.custom(FontFamily.bold.rawValue, size: 24))
                        .foregroundColor(.black)
                }
            }
            .padding()
            .background(Color("Peach"))
            
            if self.viewModel.groupsArray.count > 0 {
                
                LazyVStack {
                    ForEach(viewModel.groupsArray, id: \.id) { group in
                        Button {
                            selectedGroup = group
                            self.openGroupChat.toggle()
                        } label: {
                            HStack {
                                if let url = URL(string: group.image) {
                                    AsyncImage(url: url, content: view)
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                } else {
                                    Color.black
                                        .frame(width: 100, height: 100)
                                }
                                
                                VStack(alignment: .leading) {
                                    Text(group.name)
                                        .font(.title2)
                                        .foregroundStyle(.black)
                                        .bold()
                                    Text(group.description)
                                        .font(.title3)
                                        .foregroundStyle(.gray)
                                }
                                .padding()
                                Spacer()
                            }
                            .padding()
                        }
                    }
                }
                .padding(.top, 10)
            }
            Spacer()
        }
        .sheet(isPresented: $viewModel.showingAddGroupView) {
            AddGroupView(isPresented: $viewModel.showingAddGroupView)
        }
        .onAppear {
            viewModel.fetchGroupsByOwner(sessionManager.getCurrentAuthUser()?.uid ?? "NaN")
        }
        .navigationDestination(isPresented: $openGroupChat, destination: {
            if let selected = selectedGroup, let id = selected.id {
                GroupChatView(groupId: id)
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