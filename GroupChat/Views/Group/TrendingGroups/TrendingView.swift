//
//  TrendingView.swift
//  GroupChat
//
//  Created by Irtaza Fiaz on 03/04/2024.
//

import SwiftUI

struct TrendingView: View {
    
    @ObservedObject var viewModel: GroupsVM
    @EnvironmentObject var sessionManager: SessionManager
    
    @State private var searchText = ""
    @Binding var selectedTab: Int
    
    var body: some View {
        VStack {
            
            HStack {
                Text("Trending Groups 🔥")
                    .font(.custom(FontFamily.bold.rawValue, size: 26))
                    .foregroundColor(.black)
                Spacer()
            }
            .padding()
            .background(Color("primary-color"))
            
            SearchBar(text: $searchText)
            
            if self.viewModel.filteredGroups.count > 0 {
                
                VStack {
                    ForEach(viewModel.filteredGroups.prefix(10), id: \.id) { group in
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
                                Spacer()
                                
                                Button("Join") {
                                    if let user = sessionManager.getCurrentAuthUser() {
                                        viewModel.joinGroup(groupId: group.id ?? "NaN", userId: user.uid) { error  in
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
            Spacer()
                .onChange(of: searchText) {
                    viewModel.filterGroups(searchText)
                }
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
