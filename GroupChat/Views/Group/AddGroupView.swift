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
    
    @Binding var isPresented: Bool
    @EnvironmentObject var sessionManager: SessionManager
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var type: String = "Movies"
    
    @State private var image: UIImage?
    @State private var showImagePicker = false
    
    @State private var showAlert = false
    @State private var uploadProgress: Float = 0.0
    
    private let groupTypes = ["Movies", "Books", "Social", "Entertainment", "Sports", "Other"]
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
                                .frame(width: 60, height: 60, alignment: .center)
                                .clipShape(Circle())
                                .onTapGesture { showImagePicker = true }
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .foregroundColor(.gray)
                                .frame(width: 60, height: 60, alignment: .center)
                                .onTapGesture { showImagePicker = true }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    
                    TextField("Group Name", text: $title)
                    
                    TextField("Description", text: $description)
                    
                    Picker("Type", selection: $type) {
                        ForEach(groupTypes, id: \.self) { groupType in
                            Text(groupType).tag(groupType)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    if isUploading {
                        HStack {
                            Spacer()
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.5)
                            Spacer()
                        }
                        .frame(height: 44)
                        .background(Color.blue)
                        .cornerRadius(8)
                        .padding(.top, 10)
                    } else {
                        Button(action: handleUpload) {
                            HStack {
                                Spacer()
                                Text("Add")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .frame(height: 44)
                            .background(Color.blue)
                            .cornerRadius(8)
                        }
                        .padding(.top, 10)
                    }
                    
                }
                
            }
            .disabled(isUploading)
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $image, isShown: $showImagePicker) {}
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("OK"), action: {})
                )
            }
            .navigationTitle("Create Group")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { isPresented = false }
                }
            }
        }
    }
    
    func handleUpload() {
        self.isUploading = true

        guard let imageData = image?.jpegData(compressionQuality: 0.5) else {
            errorMessage = "Please select an image for the group."
            showAlert = true
            return
        }
        
        let path = "Images/\(UUID().uuidString)"
        let fileRef = Storage.storage().reference().child(path)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        let uploadTask = fileRef.putData(imageData, metadata: metadata)

        uploadTask.observe(.progress) { snapshot in
            self.isUploading = true
            if let progress = snapshot.progress {
                self.uploadProgress = Float(progress.fractionCompleted)
            }
        }

        uploadTask.observe(.success) { snapshot in
            self.isUploading = false
            fileRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    self.errorMessage = "Error getting the download URL."
                    self.showAlert = true
                    return
                }
                self.uploadData(group: Group(
                    name: self.title,
                    type: self.type,
                    description: self.description,
                    owner: self.sessionManager.getCurrentAuthUser()?.uid ?? "NaN",
                    image: String(describing: downloadURL)
                ))
                self.isPresented = false
            }
        }

        uploadTask.observe(.failure) { snapshot in
            self.isUploading = false
            if let error = snapshot.error as NSError? {
                self.errorMessage = error.localizedDescription
                self.showAlert = true
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
