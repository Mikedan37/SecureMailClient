//  Untitled.swift
//  MailClient
//  Created by Michael Danylchuk on 5/11/25.
import SwiftUI
import Foundation

struct SendMailView: View {
    @EnvironmentObject var accountStore: MailAccountStore

    @State private var recipientID = ""
    @State private var plaintext = ""
    @State private var status: String?
    @State private var isHovering = false
    @State private var burnAfterRead = false
    @State private var subject: String = ""
    @State private var sendViaSMTP = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("New Message")
                    .font(.title2.bold())
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                        .scaleEffect(isHovering ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: isHovering)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .onHover { hovering in
                    isHovering = hovering
                    (hovering ? NSCursor.pointingHand : NSCursor.arrow).set()
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 4)

            Divider()

            VStack(alignment: .leading, spacing: 12) {
                TextField(sendViaSMTP ? "Recipient Email Address" : "Recipient Device ID", text: $recipientID)
                    .textFieldStyle(.roundedBorder)

                TextField("Subject", text: $subject)
                    .textFieldStyle(.roundedBorder)

                TextEditor(text: $plaintext)
                    .frame(height: 120)
                    .padding(4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3))
                    )

                Toggle("Send via SMTP", isOn: $sendViaSMTP)

                if let status {
                    Text(status)
                        .foregroundColor(.secondary)
                        .padding(.top, 2)
                }
            }
            .padding(16)

            HStack(alignment: .center, spacing: 16) {
                Button {
                    Task {
                        do {
                            if sendViaSMTP {
                                guard let account = accountStore.accounts.first else {
                                    status = "❌ No SMTP account configured"
                                    return
                                }

                                let smtp = SMTPService(email: account.email, password: account.password)
                                smtp.sendEmail(to: recipientID, subject: subject, body: plaintext)
                                status = "📤 Sent via SMTP"
                                dismiss()
                            } else {
                                let pubkey = try await APIService.shared.getPublicKey(for: recipientID)
                                let encrypted = try encryptMail(plaintext, to: pubkey)

                                try await APIService.shared.sendMail(
                                    recipient: recipientID,
                                    subject: subject,
                                    ciphertext: encrypted.ciphertext,
                                    signature: encrypted.signature,
                                    burnAfterRead: burnAfterRead
                                )
                                status = "✅ Sent Securely"
                                dismiss()
                            }

                            plaintext = ""
                        } catch {
                            status = "❌ \(error.localizedDescription)"
                        }
                    }
                } label: {
                    Label("Send", systemImage: "paperplane.fill")
                }
                .buttonStyle(.borderedProminent)
                .disabled(recipientID.isEmpty || plaintext.isEmpty)

                Spacer()

                BurnAfterReadToggle(isOn: $burnAfterRead)
                    .toggleStyle(.switch)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
            .frame(height: 44)
        }
        .onAppear {
            Task {
                let pubkey = DeviceUtils.deviceID.data(using: .utf8)!.base64EncodedString()
                await APIService.shared.ensureDeviceIsRegistered(publicKey: pubkey)
            }

            recipientID = DeviceUtils.deviceID
        }
        .frame(minWidth: 400, maxHeight: .infinity)
    }
}
