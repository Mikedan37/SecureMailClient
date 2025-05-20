//  SMTPService.swift
//  MailClient
//  Created by Michael Danylchuk on 5/20/25.

import SwiftSMTP

class SMTPService {
    private let smtp: SMTP
    private let from: Mail.User

    init(email: String, password: String) {
        self.smtp = SMTP(
            hostname: "smtp.gmail.com",
            email: email,
            password: password,
            port: 587,
            tlsMode: .requireSTARTTLS,
            authMethods: [.plain, .login]
        )
        self.from = Mail.User(name: "Me", email: email)
    }

    func sendEmail(to recipient: String, subject: String, body: String) {
        let toUser = Mail.User(name: "Friend", email: recipient)
        let mail = Mail(
            from: from,
            to: [toUser],
            subject: subject,
            text: body
        )
        smtp.send(mail) { error in
            if let error = error {
                print("❌ Failed to send: \(error)")
            } else {
                print("✅ Email sent successfully!")
            }
        }
    }
}
