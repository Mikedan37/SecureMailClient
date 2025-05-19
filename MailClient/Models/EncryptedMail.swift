//  EncryptedMail.swift
//  MailClient
//  Created by Michael Danylchuk on 5/11/25.
import SwiftUI
import Foundation

struct EncryptedMail: Codable, Identifiable {
    let id: UUID
    let sender: String
    let recipient: String
    let ciphertext: String
    let signature: String
    let timestamp: Date
    let readAt: Date?
}
