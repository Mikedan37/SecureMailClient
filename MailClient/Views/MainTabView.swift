//  MainTabView.swift
//  MailClient
//  Created by Michael Danylchuk on 5/12/25.

import SwiftUI

struct MainTabView: View {
    let deviceID: String
    @State private var selectedFolder: MailboxFolder = .inbox
    @State private var hoverFolder: MailboxFolder? = nil
    @State private var showingCompose = false

    var body: some View {
        NavigationSplitView {
            VStack(alignment: .leading, spacing: 4) {
                ForEach(MailboxFolder.allCases) { folder in
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                            selectedFolder = folder
                        }
                    }) {
                        HStack(spacing: 10) {
                            iconView(for: folder)
                            Text(folder.rawValue)
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(backgroundColor(for: folder))
                        )
                    }
                    .buttonStyle(.plain)
                    .onHover { hovering in
                        hoverFolder = hovering ? folder : nil
                    }
                }
                Spacer()
            }
            .padding(10)
            .frame(minWidth: 100)
        } detail: {
            InboxView(recipientID: deviceID, folder: selectedFolder)
                .navigationTitle(selectedFolder.rawValue)
                .toolbar {
                    ToolbarItem(placement: .navigation) {
                        Button {
                            showingCompose = true
                        } label: {
                            Label("Compose", systemImage: "square.and.pencil")
                        }
                    }
                }
                .sheet(isPresented: $showingCompose) {
                    SendMailView()
                }
        }
    }

    private func iconView(for folder: MailboxFolder) -> some View {
        Image(systemName: folder.icon)
            .foregroundColor(folder.color)
            .scaleEffect(selectedFolder == folder ? 1.15 : 1.0)
            .rotationEffect(folder == .sent && selectedFolder == folder ? .degrees(-10) : .degrees(0))
            .rotationEffect(folder == .trash && selectedFolder == folder ? .degrees(10) : .degrees(0))
            .offset(y: folder == .inbox && selectedFolder == folder ? -2 : 0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedFolder)
    }

    private func backgroundColor(for folder: MailboxFolder) -> Color {
        if selectedFolder == folder {
            return Color.gray.opacity(0.2)
        } else if hoverFolder == folder {
            return Color.gray.opacity(0.1)
        } else {
            return Color.clear
        }
    }
}
