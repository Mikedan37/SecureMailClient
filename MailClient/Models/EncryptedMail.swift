//  EncryptedMail.swift
//  MailClient
//  Created by Michael Danylchuk on 5/11/25.
import SwiftUI
import Foundation

struct EncryptedMail: Identifiable, Codable, Equatable {
    let id: UUID
    let sender: String
    let recipient: String
    let ciphertext: String
    let signature: String
    let timestamp: Date?
    var readAt: Date?
    let burnAfterRead: Bool
}

extension EncryptedMail {
    var decryptedPreview: String {
        guard let data = Data(base64Encoded: ciphertext),
              let string = String(data: data, encoding: .utf8) else {
            return "⚠️ Cannot decrypt"
        }
        return string
    }
}
