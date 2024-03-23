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
                    .font(.title)
                    .foregroundColor(.black)
                Spacer()
                
                Button {
                    viewModel.showingAddGroupView.toggle()
                } label: {
                     Image(systemName: "plus.rectangle.fill.on.rectangle.fill")
                        .font(.title2)
                }
                
            }
            .padding()
            
            if self.viewModel.groupsArray.count > 0 {

                LazyVStack {
                    ForEach(0..<self.viewModel.groupsArray.count, id: \.self) { index in         
                        Button {
                            self.openGroupChat.toggle()
                        } label: {
                            HStack {
                                if let url = URL(string: self.viewModel.groupsArray[index].image) {
                                    AsyncImage(url: url, content: view)
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                } else {
                                    Color.black
                                        .frame(width: 100, height: 100)
                                }
                                
                                VStack(alignment: .leading) {
                                    Text(self.viewModel.groupsArray[index].name)
                                        .font(.title2)
                                        .foregroundStyle(.black)
                                        .bold()
                                    Text(self.viewModel.groupsArray[index].description)
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
            

            .sheet(isPresented: $viewModel.showingAddGroupView) {
                AddGroupView(isPresented: $viewModel.showingAddGroupView)
            }
            
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
