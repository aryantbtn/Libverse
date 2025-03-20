import SwiftUI

struct OTPVerificationView: View {
    let email: String
    let password: String
    
    @State private var otpFields: [String] = Array(repeating: "", count: 6)
    @FocusState private var fieldFocus: Int?
    @State private var errorMessage: String?
    @State private var navigateToHome = false
    @State private var showSuccessMessage = false
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Environment(\.dismiss) private var dismiss
        
    var otp: String {
        otpFields.joined()
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                ScrollView {
                    VStack(spacing: 30) {
                        VStack(spacing: 15) {
                            Text("Email Verification")
                                .font(.custom("Courier New", size: 25))
                                .bold()
                                .frame(width: 287, alignment: .center)
                            
                            Text("Enter the code sent to")
                                .font(.custom("Courier", size: 16))
                            
                            Text(email)
                                .font(.custom("Courier", size: 16))
                                .bold()
                        }
                        
                        HStack(spacing: 12) {
                            ForEach(0..<6, id: \.self) { index in
                                ZStack {
                                    TextField("", text: $otpFields[index], onEditingChanged: { editing in
                                        if editing {
                                            otpFields[index] = ""
                                        }
                                    })
                                    .textFieldStyle(.plain)
                                    .frame(width: 43, height: 43)
                                    .multilineTextAlignment(.center)
                                    .keyboardType(.numberPad)
                                    .focused($fieldFocus, equals: index)
                                    .onChange(of: otpFields[index]) { newValue in
                                        if newValue.count >= 1 {
                                            otpFields[index] = String(newValue.prefix(1))
                                            if index < 5 {
                                                fieldFocus = index + 1
                                            } else {
                                                fieldFocus = nil
                                            }
                                        }
                                    }
                                }
                                .overlay(
                                    RoundedRectangle(cornerRadius: 0)
                                        .stroke(Color.black, lineWidth: 1.25)
                                )
                            }
                        }
                        .padding(.horizontal)
                        
                        Button(action: verifyOTP) {
                            if isLoading {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(red: 255/255, green: 111/255, blue: 45/255))
                            } else {
                                Text("Verify")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(otp.count == 6 ? Color(red: 255/255, green: 111/255, blue: 45/255) : Color.gray)
                                    .foregroundColor(.white)
                            }
                        }
                        .disabled(otp.count != 6 || isLoading)
                        .padding(.horizontal)
                        
                        Button(action: resendCode) {
                            Text("Resend Code")
                                .font(.custom("Courier", size: 16))
                                .foregroundColor(.black)
                        }
                    }
                    .padding()
                }
                Spacer()
            }
            .overlay {
                if showSuccessMessage {
                    Text("OTP Verified Successfully!")
                        .font(.custom("Courier", size: 18))
                        .padding()
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(10)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .background(Color(red: 255/255, green: 239/255, blue: 210/255).edgesIgnoringSafeArea(.all))
            .alert("Verification", isPresented: $showAlert) {
                Button("OK") {
                    if alertMessage == "Email verified successfully!" {
                        navigateToHome = true
                    }
                }
            } message: {
                Text(alertMessage)
            }
            .navigationDestination(isPresented: $navigateToHome) {
                HomeView()
                    .navigationBarBackButtonHidden(true)
            }
            .onAppear {
                fieldFocus = 0
            }
        }
    }
    
    private func verifyOTP() {
        isLoading = true
        errorMessage = nil

        SupabaseManager.shared.verifyOTP(email: email, otp: otp) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success:
                    withAnimation {
                        showSuccessMessage = true
                    }
                    alertMessage = "Email verified successfully!"
                    showAlert = true
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    alertMessage = "Error: \(error.localizedDescription)"
                    showAlert = true
                }
            }
        }
    }
    
    private func resendCode() {
        alertMessage = "New code has been sent to your email"
        showAlert = true
    }
}
