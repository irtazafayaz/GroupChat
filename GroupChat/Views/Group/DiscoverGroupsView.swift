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
    
    var body: some View {
        NavigationView {
            VStack {
                
                if self.viewModel.notJoinedGroups.count > 0 {
                    
                    LazyVStack {
                        ForEach(viewModel.notJoinedGroups, id: \.id) { group in
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
            .navigationTitle("Discover")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
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

