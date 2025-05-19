//  APIService.swift
//  MailClient
//  Created by Michael Danylchuk on 5/11/25.
import SwiftUI
import Foundation

class APIService {
    static let shared = APIService()
    private let baseURL = URL(string: "http://10.0.0.246:8080")!

    func fetchInbox(for recipient: String) async throws -> [EncryptedMail] {
        let url = baseURL.appendingPathComponent("mailbox/\(recipient)")
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([EncryptedMail].self, from: data)
    }

    func registerDevice(deviceID: String, publicKey: String) async throws {
        let url = baseURL.appendingPathComponent("registerDevice")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let payload = ["deviceID": deviceID, "publicKey": publicKey]
        request.httpBody = try JSONEncoder().encode(payload)
        _ = try await URLSession.shared.data(for: request)
    }

    // Add: sendMail(), getPublicKey(), acknowledgeMail(), deleteMail()
}
