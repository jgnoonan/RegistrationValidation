import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ValidationViewModel()
    @State private var showPassword = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Entra ID Validation")
                .font(.title)
                .padding()
            
            TextField("Username", text: $viewModel.username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding(.horizontal)
            
            HStack {
                if showPassword {
                    TextField("Password", text: $viewModel.password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                } else {
                    SecureField("Password", text: $viewModel.password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                
                Button(action: {
                    showPassword.toggle()
                }) {
                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal)
            
            Button("Validate") {
                Task {
                    await viewModel.validateCredentials()
                }
            }
            .disabled(viewModel.username.isEmpty || viewModel.password.isEmpty)
            .buttonStyle(.borderedProminent)
            .padding()
            
            if let mobilePhone = viewModel.mobilePhone {
                Text("Mobile Phone: \(mobilePhone)")
                    .padding()
            }
            
            if let error = viewModel.error {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            }
        }
    }
}

#Preview {
    ContentView()
}
