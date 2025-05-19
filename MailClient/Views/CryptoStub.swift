//  Untitled 2.swift
//  MailClient
//  Created by Michael Danylchuk on 5/12/25.

import Foundation

struct EncryptedPayload {
    let ciphertext: String
    let signature: String
}

// 🔐 Stub encryption/signing logic — replace with real CryptoKit later
func encryptMail(_ plaintext: String, to publicKey: String) throws -> EncryptedPayload {
    let ciphertext = Data(plaintext.utf8).base64EncodedString()
    let signature = UUID().uuidString  // fake signature
    return EncryptedPayload(ciphertext: ciphertext, signature: signature)
}
