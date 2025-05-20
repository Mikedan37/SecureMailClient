SecureMailClient

A privacy-focused, multi-account email client built in SwiftUI with a Vapor backend. It supports sending encrypted mail via a custom protocol, bridging in real IMAP mail, and sending via SMTP — all stored locally and filtered by account.

Features

Core Functionality
	•	SwiftUI frontend (macOS/iOS)
	•	Vapor backend (hosted on Raspberry Pi)
	•	Encrypted custom mail protocol
	•	Send messages via SMTP (Gmail-compatible)
	•	Receive messages via IMAP using raw TCP stream (no MailCore2)

Privacy
	•	End-to-end encryption for secure messages
	•	Burn after read toggle
	•	Device-verified public key exchange

UI Features
	•	Mailbox view with folder navigation (Inbox, Sent, Trash)
	•	Compose screen with subject/body/toggles
	•	Settings panel for adding mail accounts securely
	•	Supports toggling between custom protocol vs. SMTP sending

Backend (Vapor)
	•	EncryptedMail model w/ subject, body, signature, etc.
	•	accountTag field to separate mailboxes
	•	GET /mailbox/:recipient?accountTag= filtering API
	•	Automatic device registration endpoint

Architecture

Frontend
	•	EncryptedMail: Represents any message
	•	MailAccount: Stores credentials for IMAP/SMTP
	•	MailAccountStore: ObservableObject with array of MailAccounts
	•	SMTPService: Uses SwiftSMTP to send outgoing mail
	•	RawIMAPClient: Uses InputStream/OutputStream to fetch headers from Gmail
	•	IMAPToSecureBridge: Converts IMAPMessage to EncryptedMail

Backend
	•	Swift + Vapor
	•	SQLite DB
	•	RESTful API with JSON
	•	Endpoints:
	•	POST /sendMail
	•	GET /mailbox/:recipient
	•	POST /checkDeviceExists
	•	POST /registerDevice

Getting Started

Frontend (macOS)
	1.	Clone repo
	2.	Run pod deintegrate && pod install (if CocoaPods used previously)
	3.	Use Swift Package Manager to install SwiftSMTP
	4.	Launch MailClient.xcodeproj or .xcworkspace
	5.	Add mail account in Settings (email + app password)

Backend (Raspberry Pi)
	1.	Install Swift w/ swiftly or manually
	2.	cd MailBackend
	3.	Run migrations:

swift run Run migrate
	4.	Start server:

swift run
	5.	Ensure port 8080 is exposed for external access

Security Notes
	•	SMTP passwords are app-specific and stored only in-memory via @State
	•	Messages are encrypted client-side using asymmetric keys
	•	accountTag is used to separate IMAP and encrypted inboxes cleanly

Coming Soon
	•	IMAP body fetching (not just headers)
	•	Unified inbox view
	•	OAuth2 support for Gmail
	•	Background syncing + local caching

License

This project is for educational use. No warranties, no guarantees. Encrypt everything.

Built by Michael Danylchuk
