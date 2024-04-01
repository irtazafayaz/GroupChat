//
//  DiscoverGroupsView.swift
//  GroupChat
//
//  Created by Irtaza Fiaz on 27/03/2024.
//

import SwiftUI

struct DiscoverGroupsView: View {
    
    @ObservedObject var viewModel: GroupsVM
    @EnvironmentObject var sessionManager: SessionManager
    @Binding var isPresented: Bool
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                
                SearchBar(text: $searchText)
                
                if self.viewModel.notJoinedGroups.count > 0 {
                    
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
                                                    isPresented = false
                                                } else {
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
            }
            .navigationTitle("Trending Groups")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
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

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            TextField("Search", text: $text)
                .padding(7)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal, 10)
        }
        .padding(.top, 10)
    }
}
