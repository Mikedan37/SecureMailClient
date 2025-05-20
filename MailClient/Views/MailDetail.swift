//  MailDetail.swift
//  MailClient
//  Created by Michael Danylchuk on 5/12/25.

import SwiftUI

struct MailDetailView: View {
    @Binding var mail: EncryptedMail

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("From: \(mail.sender)").bold()
            Text("To: \(mail.recipient)")
            Text("Subject: \(mail.subject)")
                .font(.title3)
                .bold()
                .padding(.vertical, 4)
            if let timestamp = mail.timestamp {
                Text("Received: \(timestamp.formatted())")
            }
            Divider()
            Text("Encrypted Message")
                .font(.headline)
            Text(mail.ciphertext)
                .font(.body)
                .padding(.top, 4)

            if let readAt = mail.readAt {
                Divider()
                Text("✅ Acknowledged: \(readAt.formatted())")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding()
        .task {
            if mail.readAt == nil {
                await APIService.shared.acknowledgeOnRead(for: mail)
                mail.readAt = Date() // ← Update local binding immediately
            }
        }
    }
}
