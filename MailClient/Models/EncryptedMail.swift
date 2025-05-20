//  EncryptedMail.swift
//  MailClient
//  Created by Michael Danylchuk on 5/11/25.
import SwiftUI
import Foundation

struct EncryptedMail: Identifiable, Codable, Equatable {
    let id: UUID
    let sender: String
    let recipient: String
    let subject: String
    let ciphertext: String?     // Made optional
    let signature: String?      // Made optional
    let timestamp: Date?
    var readAt: Date?
    let burnAfterRead: Bool
    var accountTag: String?     // 👈 New field to tag IMAP account source
}

extension EncryptedMail {
    var decryptedPreview: String {
        guard let ciphertext = ciphertext,
              let data = Data(base64Encoded: ciphertext),
              let string = String(data: data, encoding: .utf8) else {
            return "⚠️ Cannot decrypt"
        }
        return subject.isEmpty ? string : "\(subject): \(string)"
    }
}
