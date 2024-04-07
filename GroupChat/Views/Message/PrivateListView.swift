//
//  PrivateListView.swift
//  GroupChat
//
//  Created by Irtaza Fiaz on 06/04/2024.
//

import SwiftUI

struct PrivateListView: View {
    
    // MARK: Data Members
    @State private var selectedMember: UserDetails?
    @State private var openPrivateChat: Bool = false
    
    // MARK: Data Binding
    @StateObject var viewModel: PrivateVM = PrivateVM()
    @EnvironmentObject var sessionManager: SessionManager
    
    // MARK: Body
    var body: some View {
        VStack {
            
            HStack {
                Text("Private Chat")
                    .font(.custom(FontFamily.bold.rawValue, size: 30))
                    .foregroundColor(.black)
                Spacer()
            }
            .padding()
            .background(Color("primary-color"))
            
            if viewModel.isLoading {
                if self.viewModel.members.count > 0 {
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(viewModel.members, id: \.id) { member in
                                Button {
                                    selectedMember = member
                                    self.openPrivateChat.toggle()
                                } label: {
                                    VStack {
                                        HStack {
                                            if let url = URL(string: member.photoURL) {
                                                AsyncImage(url: url, content: view)
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: 50, height: 50)
                                                    .clipShape(Circle())
                                            } else {
                                                Color.black
                                                    .frame(width: 50, height: 50)
                                            }
                                            
                                            VStack(alignment: .leading) {
                                                Text(member.displayName.uppercased())
                                                    .font(.custom(FontFamily.bold.rawValue, size: 20))
                                                    .foregroundStyle(.black)
                                                    .bold()
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
            } else {
                Spacer()
                ProgressView()
                Spacer()
            }
        }
        .onAppear {
            viewModel.startOrRetrieveChat(senderId: sessionManager.getCurrentAuthUser()?.uid ?? "NaN")
        }
        .navigationDestination(isPresented: $openPrivateChat, destination: {
            if let memberId = selectedMember?.id {
                PrivateChatView(receiverId: memberId)
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
    PrivateListView(viewModel: PrivateVM())
}

