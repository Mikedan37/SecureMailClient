//
//  MailClientApp.swift
//  MailClient
//
//  Created by Michael Danylchuk on 5/11/25.
//

import SwiftUI

@main
struct MailClientApp: App {
    @StateObject private var accountStore = MailAccountStore()
    
    var body: some Scene {
        WindowGroup {
            MainTabView(deviceID: "macbook-pro-001").environmentObject(accountStore)
        }
    }
}
