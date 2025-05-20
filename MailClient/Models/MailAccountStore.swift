//  MailAccountStore.swift
//  MailClient
//  Created by Michael Danylchuk on 5/20/25.

import Foundation

class MailAccountStore: ObservableObject {
    @Published var accounts: [MailAccount] = []
}
