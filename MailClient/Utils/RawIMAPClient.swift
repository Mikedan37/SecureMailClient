//  RawIMAPClient.swift
//  MailClient
//  Created by Michael Danylchuk on 5/20/25.
import Foundation

struct IMAPMessage: Identifiable {
    let id: String
    let subject: String
    let from: String
    let date: String
}

class RawIMAPClient: NSObject, StreamDelegate {
    private var inputStream: InputStream?
    private var outputStream: OutputStream?
    private var buffer = Data()
    private var tagCounter = 1
    private var currentTag: String { "a\(tagCounter)" }

    private var onComplete: (([IMAPMessage]) -> Void)?
    private var currentState: State = .idle
    private var messages: [IMAPMessage] = []
    private var activeAccount: MailAccount? = nil

    enum State {
        case idle
        case login
        case selectInbox
        case fetchHeaders
    }

    func fetchInboxHeaders(account: MailAccount, completion: @escaping ([IMAPMessage]) -> Void) {
        self.onComplete = completion
        self.currentState = .login
        self.activeAccount = account

        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        CFStreamCreatePairWithSocketToHost(nil, account.imapHost as CFString, 993, &readStream, &writeStream)

        inputStream = readStream!.takeRetainedValue()
        outputStream = writeStream!.takeRetainedValue()

        inputStream?.delegate = self
        outputStream?.delegate = self

        inputStream?.schedule(in: .current, forMode: .default)
        outputStream?.schedule(in: .current, forMode: .default)

        inputStream?.open()
        outputStream?.open()
    }

    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case .hasBytesAvailable:
            readAvailableBytes(stream: aStream as! InputStream)
        case .endEncountered:
            closeStreams()
        default:
            break
        }
    }

    private func readAvailableBytes(stream: InputStream) {
        let maxLength = 4096
        var buffer = [UInt8](repeating: 0, count: maxLength)

        while stream.hasBytesAvailable {
            let bytesRead = stream.read(&buffer, maxLength: maxLength)
            if bytesRead > 0 {
                if let response = String(bytes: buffer[0..<bytesRead], encoding: .utf8) {
                    handleResponse(response)
                }
            }
        }
    }

    private func handleResponse(_ response: String) {
        print("⬅️ \(response)")
        switch currentState {
        case .login:
            sendCommand("\(currentTag) LOGIN \(emailEscaped) \(passwordEscaped)")
            currentState = .selectInbox
        case .selectInbox:
            sendCommand("\(currentTag) SELECT INBOX")
            currentState = .fetchHeaders
        case .fetchHeaders:
            sendCommand("\(currentTag) FETCH 1:* (BODY[HEADER.FIELDS (SUBJECT FROM DATE)])")
            currentState = .idle
        case .idle:
            let lines = response.split(separator: "\r\n")
            for line in lines {
                if line.contains("Subject") {
                    messages.append(IMAPMessage(id: UUID().uuidString, subject: line.description, from: "", date: ""))
                }
            }
            onComplete?(messages)
            closeStreams()
        }
        tagCounter += 1
    }

    private func sendCommand(_ command: String) {
        let commandWithNewline = command + "\r\n"
        print("➡️ \(commandWithNewline)")
        let data = commandWithNewline.data(using: .utf8)!
        _ = data.withUnsafeBytes {
            outputStream?.write($0.bindMemory(to: UInt8.self).baseAddress!, maxLength: data.count)
        }
    }

    private func closeStreams() {
        inputStream?.close()
        outputStream?.close()
        inputStream = nil
        outputStream = nil
    }

    private var emailEscaped: String {
        guard let email = activeAccount?.email else { return "\"\"" }
        return "\"\(email)\""
    }

    private var passwordEscaped: String {
        guard let password = activeAccount?.password else { return "\"\"" }
        return "\"\(password)\""
    }
}

