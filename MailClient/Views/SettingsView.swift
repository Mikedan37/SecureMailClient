//  SettingsView.swift
//  MailClient
//  Created by Michael Danylchuk on 5/13/25.
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var accountStore: MailAccountStore
    @State private var newEmail: String = ""
    @State private var newPassword: String = ""

    var body: some View {
        Form {
            Section(header: Text("Mail Accounts")) {
                if accountStore.accounts.isEmpty {
                    Text("No accounts added.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(accountStore.accounts) { account in
                        HStack {
                            Text(account.email)
                            Spacer()
                            Image(systemName: "key.fill")
                                .foregroundColor(.gray)
                        }
                    }
                    .onDelete { indexSet in
                        accountStore.accounts.remove(atOffsets: indexSet)
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

                    let newAccount = MailAccount(
                        email: newEmail,
                        imapHost: "imap.gmail.com",     // TODO: make dynamic later
                        smtpHost: "smtp.gmail.com",
                        username: newEmail,
                        password: newPassword
                    )

                    accountStore.accounts.append(newAccount)
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
