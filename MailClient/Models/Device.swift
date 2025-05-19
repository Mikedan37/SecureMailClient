//  Device.swift
//  MailClient
//  Created by Michael Danylchuk on 5/11/25.

import SwiftUI
import Foundation

struct Device: Codable, Identifiable {
    let id: UUID
    let deviceID: String
    let publicKey: String
    let createdAt: Date
}
