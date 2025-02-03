import Foundation
import GRPC
import NIOCore
import SwiftProtobuf
import Network

@MainActor
class ValidationViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""
    @Published var mobilePhone: String?
    @Published var error: String?
    
    private let group = PlatformSupport.makeEventLoopGroup(loopCount: 1)
    private lazy var channel = try? GRPCChannelPool.with(
        target: .host("localhost", port: 50051),
        transportSecurity: .plaintext,
        eventLoopGroup: group
    )
    
    func validateCredentials() async {
        print("Starting validation for user: \(username)")
        
        guard let channel = channel else {
            error = "Failed to create channel"
            print("Channel creation failed")
            return
        }
        
        let request = ValidateCredentialsRequest.with {
            $0.userID = username
            $0.password = password
        }
        
        print("Sending request to server...")
        
        do {
            let client = LdapValidationServiceNIOClient(channel: channel)
            print("Created client, making request...")
            
            let call = client.validateCredentials(request)
            print("Made RPC call, waiting for response...")
            
            let response = try await call.response.get()
            print("Received response: \(response)")
            
            switch response.result {
            case .phoneNumber(let phone):
                print("Success - received phone: \(phone)")
                self.mobilePhone = phone
                self.error = nil
            case .error(let validationError):
                print("Error received: \(validationError.message)")
                self.error = validationError.message
                self.mobilePhone = nil
            case .none:
                print("No result received")
                self.error = "Unknown error occurred"
                self.mobilePhone = nil
            }
        } catch {
            print("Error occurred: \(error)")
            self.error = error.localizedDescription
            self.mobilePhone = nil
        }
    }
    
    deinit {
        try? group.syncShutdownGracefully()
    }
}
