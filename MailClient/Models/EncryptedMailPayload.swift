//  EncryptedMailPayload.swift
//  MailClient
//  Created by Michael Danylchuk on 5/13/25.

private struct EncryptedMailPayload: Codable {
    let sender: String
    let recipient: String
    let subject: String
    let ciphertext: String
    let signature: String
    let burnAfterRead: Bool
}
