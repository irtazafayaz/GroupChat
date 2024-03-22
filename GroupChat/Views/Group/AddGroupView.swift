//
//  AddGroupView.swift
//  GroupChat
//
//  Created by Irtaza Fiaz on 22/03/2024.
//

import SwiftUI
import FirebaseStorage
import FirebaseFirestore

struct AddGroupView: View {
    
    @State var isUploading = false
    @State private var errorMessage: String = ""
    
    @Environment(\.dismiss) var dismiss
//    var createGroup: (Group) -> Void
    
    @Binding var isPresented: Bool
    @EnvironmentObject var sessionManager: SessionManager
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var type: String = ""
    
    @State private var image: UIImage?
    @State private var showImagePicker = false
    
    private let db = Firestore.firestore()
    
    var body: some View {
        NavigationView {
            Form {
                
                Section(header: Text("Create Group")) {
                    
                    VStack {
                        if let selectedImage = image {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100, alignment: .center)
                                .clipShape(Circle())
                                .onTapGesture {
                                    showImagePicker = true
                                }
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .foregroundColor(.gray)
                                .frame(width: 100, height: 100, alignment: .center)
                                .onTapGesture {
                                    showImagePicker = true
                                }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                    
                    TextField("Group Name", text: $title)
                    
                    TextField("Description", text: $description)
                    
                    TextField("Type", text: $type)
                    
                }
                
                Button("Add Transaction") {
                    // Add logic to create and save a new transaction
                    handleUpload()
                }
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
                
                if self.isUploading {
                    ProgressView()
                        .scaleEffect(2)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.gray.opacity(0.5))
                }
                
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $image, isShown: $showImagePicker) {
                }
            }
            .navigationTitle("Create Group")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
    
    func handleUpload() {
        guard image != nil else {
            return
        }
        let storageRef = Storage.storage().reference()
        let imageData = image?.jpegData(compressionQuality: 0.5)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        guard imageData != nil else {
            return
        }
        
        let path = "Images/\(UUID().uuidString)"
        let fileRef = storageRef.child(path)
        let uploadTask = fileRef.putData(imageData!, metadata: metadata)
        
        uploadTask.observe(.progress) { snapshot in
            self.isUploading = true
        }
        
        uploadTask.observe(.success) { snapshot in
            isUploading = false
            fileRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    return
                }
                uploadData(group: Group(
                    name: title,
                    type: type,
                    description: description,
                    owner: sessionManager.getCurrentAuthUser()?.uid ?? "NaN",
                    image: String(describing: downloadURL)
                ))
                isPresented.toggle()
                
            }
            
            
            uploadTask.observe(.failure) { snapshot in
                self.isUploading = false
                if let error = snapshot.error as? NSError {
                    switch StorageErrorCode(rawValue: error.code) {
                    case .objectNotFound:
                        self.errorMessage = "File doesn't exist"
                    case .unauthorized:
                        self.errorMessage = "User doesn't have permission to access the file"
                    case .cancelled:
                        self.errorMessage = "User canceled the upload"
                    case .unknown:
                        self.errorMessage = "Unknown error occurred"
                    default:
                        self.errorMessage = "A separate error occurred. This is a good place to retry the upload."
                    }
                }
            }
        }
    }
    
    func uploadData(group: Group) {
        
        let group: [String: Any] = [
            "name": group.name,
            "type": group.type,
            "description":  group.description,
            "owner": group.owner,
            "image": group.image,
        ]
        
        db.collection("groups").document().setData(group) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
}

//#Preview {
//    AddGroupView(addGroup: { _ in })
//}
