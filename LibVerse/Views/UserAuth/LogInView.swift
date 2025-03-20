import SwiftUI
import Supabase

struct LogInView: View {
    @State private var collegeEmail: String = ""
    @State private var password: String = ""
    
    @State private var isLoggedIn: Bool = false // State to control navigation
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    let client = SupabaseClient(
        supabaseURL: URL(string: "https://cdhawptmjahlirkdjqkt.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNkaGF3cHRtamFobGlya2RqcWt0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDIyOTM4OTAsImV4cCI6MjA1Nzg2OTg5MH0.gtp_OZQAuevaUSc-zs6QpFxU9oXt-YrX1DDCSOX4FEE"
    )
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        Image("Logo")
                            .resizable()
                            .frame(width: 120, height: 120)
                            .foregroundColor(Color(red: 255/255, green: 111/255, blue: 45/255))
                        
                        VStack(spacing: 15) {
                            Text("Get the most out of Libverse")
                                .font(.custom("Courier New", size: 25))
                                .bold()
                                .multilineTextAlignment(.center)
                            
                            Text("Unlock the full access of the world’s most fascinating digital library, Discover millions of ebooks, audiobooks, magazines and more.")
                                .font(.custom("Courier", size: 16))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        
                        // Form Fields
                        Group {
                            customTextField(placeholder: "College Email", text: $collegeEmail, keyboardType: .emailAddress, autocapitalization: .none)
                            
                            customSecureField(placeholder: "Password", text: $password)
                        }
                        
                        // Forgot Password Link
                        HStack {
                            Spacer()
                            Button(action: {}) {
                                Text("Forgot Password")
                                    .font(.custom("Courier", size: 16))
                                    .foregroundColor(.black)
                            }
                        }
                        
                        // Log In Button
                        Button(action: logIn) {
                            Text("Log In")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(red: 255/255, green: 111/255, blue: 45/255))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                        // Navigation to SignUpView
                        NavigationLink(destination: SignUpView().navigationBarBackButtonHidden(true)) {
                            Text("New User? Sign Up")
                                .font(.custom("Courier", size: 16))
                                .foregroundColor(.black)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .background(Color(red: 255/255, green: 239/255, blue: 210/255).edgesIgnoringSafeArea(.all))
            .navigationDestination(isPresented: $isLoggedIn) {
                HomeView()
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    // Custom text field with placeholder font and color
    private func customTextField(placeholder: String, text: Binding<String>, keyboardType: UIKeyboardType = .default, autocapitalization: UITextAutocapitalizationType = .words) -> some View {
        ZStack(alignment: .leading) {
            if text.wrappedValue.isEmpty {
                Text(placeholder)
                    .font(.custom("Courier", size: 16))
                    .foregroundColor(.black)
                    .padding(.leading, 10)
            }
            TextField("", text: text)
                .padding()
                .frame(height: 43)
                .keyboardType(keyboardType)
                .autocapitalization(autocapitalization)
                .overlay(
                    RoundedRectangle(cornerRadius: 0)
                        .stroke(Color.black, lineWidth: 1.25)
                )
        }
    }
    
    // Custom secure field with placeholder font and color
    private func customSecureField(placeholder: String, text: Binding<String>) -> some View {
        ZStack(alignment: .leading) {
            if text.wrappedValue.isEmpty {
                Text(placeholder)
                    .font(.custom("Courier", size: 16))
                    .foregroundColor(.black)
                    .padding(.leading, 10)
            }
            SecureField("", text: text)
                .padding()
                .frame(height: 43)
                .overlay(
                    RoundedRectangle(cornerRadius: 0)
                        .stroke(Color.black, lineWidth: 1.25)
                )
        }
    }
    
    private func logIn() {
        // Validate email domain
        let collegeDomain = ".edu.in"
        guard collegeEmail.hasSuffix(collegeDomain) else {
            alertMessage = "Please use your college email address (\(collegeDomain))."
            showAlert = true
            return
        }
        
        // Send magic link
        Task {
            do {
                try await client.auth.signIn(email: collegeEmail, password: password)
                isLoggedIn = true // Navigate to HomeView on successful login
            } catch {
                alertMessage = "Error sending magic link: \(error.localizedDescription)"
                showAlert = true
            }
        }
    }
}

#Preview {
    LogInView()
}
