//  SentToSelfTests.swift
//  MailClient
//  Created by Michael Danylchuk on 5/12/25.

import XCTest
@testable import MailClient

final class SendToSelfTests: XCTestCase {
    let testDeviceID = UIDevice.current.name
        .replacingOccurrences(of: " ", with: "-")
        .lowercased()

    func testSendToSelfAndAcknowledge() async throws {
        // Step 1: Prepare test message
        let plaintext = "test-\(UUID().uuidString)"
        let encoded = Data(plaintext.utf8).base64EncodedString()

        // Step 2: Send to self
        try await APIService.shared.sendMail(
            sender: testDeviceID,
            recipient: testDeviceID,
            ciphertext: encoded,
            signature: "FAKE_SIG",
            burnAfterRead: false
        )

        // Step 3: Fetch inbox
        let inbox = try await APIService.shared.fetchInbox(for: testDeviceID)

        guard let message = inbox.first(where: { $0.ciphertext == encoded }) else {
            XCTFail("Message not found in inbox")
            return
        }

        // Step 4: Acknowledge it
        try await APIService.shared.acknowledgeMail(id: message.id)

        // Step 5: Re-fetch to verify readAt was set
        let updatedInbox = try await APIService.shared.fetchInbox(for: testDeviceID)
        let updated = updatedInbox.first(where: { $0.id == message.id })

        XCTAssertNotNil(updated?.readAt, "readAt should be set after acknowledgment")
    }

    func testBurnAfterReadDeletesOnFetch() async throws {
        // Step 1: Prepare burnable message
        let unique = UUID().uuidString
        let encoded = Data("burn-\(unique)".utf8).base64EncodedString()

        try await APIService.shared.sendMail(
            sender: testDeviceID,
            recipient: testDeviceID,
            ciphertext: encoded,
            signature: "SIG_BURN",
            burnAfterRead: true
        )

        // Step 2: Fetch inbox to trigger burn
        _ = try await APIService.shared.fetchInbox(for: testDeviceID)

        // Step 3: Fetch again — should be gone
        let after = try await APIService.shared.fetchInbox(for: testDeviceID)
        let burned = after.first(where: { $0.ciphertext == encoded })

        XCTAssertNil(burned, "Burn-after-read mail should be deleted after read")
    }
}
