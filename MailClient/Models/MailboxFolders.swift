//  MailBox.swift
//  MailClient
//  Created by Michael Danylchuk on 5/12/25.
import SwiftUI

enum MailboxFolder: String, CaseIterable, Identifiable {
    case inbox = "Inbox"
    case sent = "Sent"
    case trash = "Trash"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .inbox: return "tray.full"
        case .sent: return "paperplane"
        case .trash: return "trash"
        }
    }

    var color: Color {
        switch self {
        case .inbox: return .blue
        case .sent: return .green
        case .trash: return .red
        }
    }
}
