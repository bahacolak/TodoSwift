import Foundation
import SwiftData

@Model
class User {
    var email: String
    var password: String
    var createdAt: Date
    
    init(email: String, password: String) {
        self.email = email
        self.password = password
        self.createdAt = Date()
    }
} 