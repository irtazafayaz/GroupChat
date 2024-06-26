import SwiftUI

struct LoginView: View {
    
    @EnvironmentObject var sessionManager: SessionManager
    
    @State private var email = ""
    @State private var password = ""
    @State private var presentPopup = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 10) {
                Spacer()
                Image("app-logo")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundStyle(Color("primary-color"))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                Text("Buzz Group Chat")
                    .foregroundStyle(.white)
                    .font(.largeTitle).bold()
                    .padding(.bottom, 40)
                
                CustomTextField(label: $email, textfieldType: .email)
                CustomTextField(label: $password, textfieldType: .password)

                Button {
                    sessionManager.login(email: email, password: password)
                } label: {
                    Text("Login")
                        .frame(width: 200)
                        .foregroundColor(.white)
                        .padding(.vertical, 15)
                        .background(.black)
                        .cornerRadius(10)
                }

                
                
                Button {
                    presentPopup.toggle()
                } label: {
                    Text("🔔how to deal with inappropriate messages?🔔")
                        .font(Font.system(size: 16))
                        .foregroundColor(.black)
                }
                .padding(.top, 10)

                
                Spacer()

                
                HStack {
                    Text("Don't have an account?")
                        .font(Font.system(size: 16))
                        .foregroundColor(.white)
                    Button(action: { sessionManager.authState = .register }) {
                        Text("Register")
                            .font(Font.system(size: 16))
                            .bold()
                            .underline()
                            .foregroundColor(.white)
                    }
                }
                .foregroundColor(.white)
                
                Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")")
                    .font(.footnote)
                    .foregroundColor(.black)
                    .padding(.bottom, 15)
                
            }
            .padding()
            .background(Color("app-background"))
            .blur(radius: sessionManager.isLoading ? 3 : 0)
            
            if sessionManager.isLoading {
                Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
                
                ProgressView()
                    .scaleEffect(2)
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            }
            
            if presentPopup {
                Popup(isPresented: $presentPopup) {
                    VStack {
                        Text("🔔")
                            .font(Font.system(size: 50))
                        Text("😒 remove them as friend")
                            .font(Font.system(size: 18))
                            .multilineTextAlignment(.leading)
                            .padding(.top, 20)
                        Text("😨 report inappropriate messages")
                            .font(Font.system(size: 18))
                            .multilineTextAlignment(.leading)
                            .padding(.top, 5)
                        Text("🥴 leave group with inappropriate content")
                            .font(Font.system(size: 18))
                            .multilineTextAlignment(.center)
                            .padding(.top, 5)
                    }
                    
                    
                }
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    LoginView().environmentObject(SessionManager())
}
