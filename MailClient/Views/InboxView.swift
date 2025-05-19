//  ContentView.swift
//  MailClient
//  Created by Michael Danylchuk on 5/11/25.
import SwiftUI

struct InboxView: View {
    @State private var messages: [EncryptedMail] = []
    @State private var lastUpdated: Date? = nil
    @State private var isUpdating: Bool = false
    @State private var isHoveringSettings = false
    @State private var isHoveringRefresh = false
    @State private var autoRefreshTask: Task<Void, Never>? = nil

    let recipientID: String
    let folder: MailboxFolder

    var body: some View {
        NavigationStack {
            VStack(spacing: 4) {
                if let updated = lastUpdated {
                    Button {
                        Task {
                            isUpdating = true
                            await refresh()
                            try? await Task.sleep(nanoseconds: 1_000_000_000)
                            isUpdating = false
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text(isUpdating ? "Updating..." : "Last updated: \(updated.formatted(.dateTime.hour().minute().second()))")
                                .font(.caption2)
                                .foregroundColor(.gray)
                                .scaleEffect(isHoveringRefresh ? 1.05 : 1.0)
                                .animation(.easeInOut(duration: 0.2), value: isHoveringRefresh)
                            if isUpdating {
                                ProgressView()
                                    .scaleEffect(0.5)
                            }
                        }
                        .padding(.top, 4)
                    }
                    .buttonStyle(.plain)
                    .onHover { hovering in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isHoveringRefresh = hovering
                        }
                    }
                }

                List {
                    ForEach($messages, id: \.id) { $mail in
                        NavigationLink {
                            MailDetailView(mail: $mail)
                        } label: {
                            MailRowView(mail: mail)
                        }
                        .listRowSeparator(.hidden)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                Task {
                                    try? await APIService.shared.deleteMail(id: mail.id)
                                    await refresh()
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                Task {
                                    try? await APIService.shared.acknowledgeMail(id: mail.id)
                                    await refresh()
                                }
                            } label: {
                                Label("Acknowledge", systemImage: "checkmark")
                            }
                            .tint(.blue)
                        }
                    }
                }
                .listStyle(.plain)
                .animation(.easeInOut(duration: 0.3), value: messages)
            }
            .navigationTitle(folder.rawValue)
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape.fill")
                            .imageScale(.large)
                            .rotationEffect(.degrees(isHoveringSettings ? 90 : 0))
                            .scaleEffect(isHoveringSettings ? 1.2 : 1.0)
                            .foregroundColor(.gray)
                            .padding(8)
                            .background(Color.secondary.opacity(0.1))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .onHover { hovering in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isHoveringSettings = hovering
                        }
                    }
                }
            }
        }
        .onAppear {
            // only trigger once
            if autoRefreshTask == nil {
                autoRefreshTask = Task {
                    await refresh()
                    await startAutoRefresh()
                }
            }
        }
        .onDisappear {
            autoRefreshTask?.cancel()
            autoRefreshTask = nil
        }
    }

    private func refresh() async {
        do {
            let fetched = try await APIService.shared.fetchInbox()
            await MainActor.run {
                self.messages = fetched
                self.lastUpdated = Date()
            }
        } catch {
            if (error as? URLError)?.code != .cancelled {
                print("❌ Failed to fetch inbox: \(error)")
            }
        }
    }

    private func startAutoRefresh() async {
        while !Task.isCancelled {
            try? await Task.sleep(nanoseconds: 60_000_000_000)
            await refresh()
        }
    }
}

struct MailRowView: View {
    let mail: EncryptedMail

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text("From: \(mail.sender)")
                    .font(.headline)

                Text(mail.decryptedPreview)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .lineLimit(1)

                if let timestamp = mail.timestamp {
                    Text("Received: \(timestamp.formatted(.dateTime.hour().minute()))")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            VStack(spacing: 4) {
                if mail.burnAfterRead {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.red)
                        .font(.system(size: 28))
                        .scaleEffect(mail.readAt != nil ? 0.8 : 1.2)
                        .opacity(mail.readAt != nil ? 0.3 : 1)
                        .animation(.easeInOut(duration: 0.2), value: mail.readAt)
                }

                Image(systemName: mail.readAt == nil ? "eye.slash" : "eye")
                    .foregroundColor(mail.readAt == nil ? .gray : .green)
                    .font(.system(size: 16))
                    .transition(.scale.combined(with: .opacity))
                    .animation(.easeInOut(duration: 0.3), value: mail.readAt)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.secondary.opacity(0.05))
        )
        .shadow(radius: 1)
    }
}
