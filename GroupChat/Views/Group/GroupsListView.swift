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
    
    var body: some View {
        VStack {
            
            HStack {
                Text("Groups")
                    .foregroundColor(.black)
                    .padding(.leading, 15)
                Spacer()
                
                
                Button {
                    viewModel.showingAddGroupView.toggle()
                } label: {
                     Image(systemName: "plus.rectangle.fill.on.rectangle.fill")
                }
                
            }
            .padding(.top, 65)
            
            if self.viewModel.groupsArray.count > 0 {

                LazyVStack {
                    ForEach(0..<self.viewModel.groupsArray.count, id: \.self) { index in
                        
                        HStack {
                            if let url = URL(string: self.viewModel.groupsArray[index].image) {
                                AsyncImage(url: url, content: view)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                            } else {
                                Color.black
                                    .frame(width: 100, height: 100)
                            }
                            
                            VStack {
                                Text(self.viewModel.groupsArray[index].name)
                                Text(self.viewModel.groupsArray[index].description)
                            }
                            
                            Spacer()
                            
                        }
                        .padding()

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
