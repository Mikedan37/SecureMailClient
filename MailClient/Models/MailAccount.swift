//  MailAccount.swift
//  MailClient
//  Created by Michael Danylchuk on 5/20/25.

import Foundation

struct MailAccount: Identifiable, Codable {
    let id: UUID = UUID()
    let email: String
    let imapHost: String
    let smtpHost: String
    let username: String
    let password: String
}
