//  APIService.swift
//  MailClient
//  Created by Michael Danylchuk on 5/11/25.
import SwiftUI
import Foundation

private struct EncryptedMailPayload: Codable {
    let sender: String
    let recipient: String
    let ciphertext: String
    let signature: String
    let burnAfterRead: Bool
}

class APIService {
    static let shared = APIService()
    private let baseURL = URL(string: "http://10.0.0.246:8080")!

    private let encoder: JSONEncoder = {
        let enc = JSONEncoder()
        enc.dateEncodingStrategy = .iso8601
        return enc
    }()

    private let decoder: JSONDecoder = {
        let dec = JSONDecoder()
        dec.dateDecodingStrategy = .iso8601
        return dec
    }()

    // ✅ Fetch inbox
    func fetchInbox() async throws -> [EncryptedMail] {
        let id = DeviceUtils.deviceID
        let url = baseURL.appendingPathComponent("mailbox/\(id)")
        let (data, _) = try await URLSession.shared.data(from: url)
        return try decoder.decode([EncryptedMail].self, from: data)
    }

    // ✅ Send encrypted mail (auto sender ID)
    func sendMail(
        recipient: String,
        ciphertext: String,
        signature: String,
        burnAfterRead: Bool
    ) async throws {
        let url = baseURL.appendingPathComponent("sendEncryptedMail")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload = EncryptedMailPayload(
            sender: DeviceUtils.deviceID,
            recipient: recipient,
            ciphertext: ciphertext,
            signature: signature,
            burnAfterRead: burnAfterRead
        )

        request.httpBody = try encoder.encode(payload)

        let (_, response) = try await URLSession.shared.data(for: request) // ✅ not decoding anything here
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
    }
    
    func registerDevice(deviceID: String, publicKey: String) async throws {
        let url = baseURL.appendingPathComponent("registerDevice")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload = ["deviceID": deviceID, "publicKey": publicKey]
        request.httpBody = try encoder.encode(payload)

        _ = try await URLSession.shared.data(for: request)
    }
    
    func ensureDeviceIsRegistered(publicKey: String) async {
            let id = DeviceUtils.deviceID
            do {
                _ = try await getPublicKey(for: id) // Will succeed if already registered
            } catch {
                if let urlError = error as? URLError, urlError.code == .badServerResponse {
                    print("🔐 Server returned bad response")
                } else {
                    print("ℹ️ Registering device \(id)...")
                    do {
                        try await APIService.shared.registerDevice(deviceID: id, publicKey: publicKey)
                        print("✅ Registered \(id)")
                    } catch {
                        print("❌ Failed to register \(id): \(error)")
                    }
                }
            }
        }
    

    func acknowledgeMail(id: UUID) async throws {
        let url = baseURL.appendingPathComponent("acknowledgeMail")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let payload = ["id": id.uuidString]
        request.httpBody = try encoder.encode(payload)
        _ = try await URLSession.shared.data(for: request)
    }

    func acknowledgeOnRead(for mail: EncryptedMail) async {
        guard mail.readAt == nil else { return }
        try? await acknowledgeMail(id: mail.id)
    }

    func deleteMail(id: UUID) async throws {
        let url = baseURL.appendingPathComponent("mailbox/\(id.uuidString)")
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        _ = try await URLSession.shared.data(for: request)
    }

    func getPublicKey(for deviceID: String) async throws -> String {
        let url = baseURL.appendingPathComponent("publicKey/\(deviceID)")
        let (data, _) = try await URLSession.shared.data(from: url)

        struct PublicKeyResponse: Codable {
            let publicKey: String
        }

        return try decoder.decode(PublicKeyResponse.self, from: data).publicKey
    }

    func fetchSent(for recipient: String) async throws -> [EncryptedMail] {
        return [
            EncryptedMail(
                id: UUID(),
                sender: recipient,
                recipient: "example@domain.com",
                ciphertext: Data("Sent message content".utf8).base64EncodedString(),
                signature: "SIGNED_SENT",
                timestamp: Date().addingTimeInterval(-3600),
                readAt: Date(), burnAfterRead: false
            )
        ]
    }

    func fetchTrash(for recipient: String) async throws -> [EncryptedMail] {
        return [
            EncryptedMail(
                id: UUID(),
                sender: "deleted@domain.com",
                recipient: recipient,
                ciphertext: Data("Deleted message content".utf8).base64EncodedString(),
                signature: "SIGNED_TRASH",
                timestamp: Date().addingTimeInterval(-7200),
                readAt: Date(), burnAfterRead: false
            )
        ]
    }
}
