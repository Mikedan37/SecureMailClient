//  IMAPToSecureBridge.swift
//  MailClient
//  Created by Michael Danylchuk on 5/20/25.

import Foundation

class IMAPToSecureBridge {
    static func convert(messages: [IMAPMessage], for account: MailAccount) -> [EncryptedMail] {
        return messages.map { imap in
            EncryptedMail(
                id: UUID(),
                sender: imap.from,
                recipient: account.email,
                subject: imap.subject,
                ciphertext: nil,
                signature: nil,
                timestamp: Self.parseDate(imap.date),
                readAt: nil,
                burnAfterRead: false,
                accountTag: account.email
            )
        }
    }
    private static func parseDate(_ string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "d-MMM-yyyy HH:mm:ss Z"
        return formatter.date(from: string)
    }
}
