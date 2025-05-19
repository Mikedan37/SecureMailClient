//  SettingsView.swift
//  MailClient
//  Created by Michael Danylchuk on 5/13/25.
import SwiftUI

struct MailAccount: Identifiable, Hashable {
    let id = UUID()
    var email: String
    var password: String
}

struct SettingsView: View {
    @State private var accounts: [MailAccount] = []
    @State private var newEmail: String = ""
    @State private var newPassword: String = ""

    var body: some View {
        Form {
            Section(header: Text("Mail Accounts")) {
                if accounts.isEmpty {
                    Text("No accounts added.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(accounts) { account in
                        HStack {
                            Text(account.email)
                            Spacer()
                            Image(systemName: "key.fill")
                                .foregroundColor(.gray)
                        }
                    }
                    .onDelete { indexSet in
                        accounts.remove(atOffsets: indexSet)
                    }
                }
            }

            Section(header: Text("Add New Account")) {
                TextField("Email", text: $newEmail)
                    .textContentType(.emailAddress)
                    #if os(iOS)
                    .autocapitalization(.none)
                    #endif

                SecureField("App Password / Token", text: $newPassword)

                Button("Add Account") {
                    guard !newEmail.isEmpty, !newPassword.isEmpty else { return }
                    let newAccount = MailAccount(email: newEmail, password: newPassword)
                    accounts.append(newAccount)
                    newEmail = ""
                    newPassword = ""
                }
                .disabled(newEmail.isEmpty || newPassword.isEmpty)
            }
        }
        .formStyle(.grouped)
        .padding()
        .navigationTitle("Settings")
    }
}
