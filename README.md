# SecureMailClient

<p align="center">
  <img src="docs/banner.png" alt="SecureMailClient" width="600"/>
</p>

![Swift](https://img.shields.io/badge/Swift-5.9-orange?logo=swift)
![Vapor](https://img.shields.io/badge/Backend-Vapor_4-blue?logo=vapor)
![Platform](https://img.shields.io/badge/Platform-macOS-lightgrey?logo=apple)
![Status](https://img.shields.io/badge/Status-In_Development-yellow)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

SecureMailClient is a multi-provider, privacy-focused email application built with a SwiftUI frontend and a Vapor backend. It provides robust end-to-end encryption for custom protocol messages while also integrating standard email functionality through IMAP and SMTP. All messages are normalized to a unified protocol format, enabling consistent rendering and secure message storage.

---

## Table of Contents
- [Overview](#overview)
- [Features](#features)
- [Project Structure](#project-structure)
- [Setup Instructions](#setup-instructions)
- [API Reference](#api-reference)
- [Roadmap](#roadmap)
- [Security Notes](#security-notes)
- [License](#license)
- [Author](#author)

---

## Overview

SecureMailClient supports:
- Sending encrypted messages via a custom protocol
- Sending standard emails via SMTP (Gmail-compatible)
- Receiving emails via IMAP using native Swift `InputStream`/`OutputStream`
- Tagging and filtering messages by `accountTag` for multi-account support

---

## Features

### Core Capabilities
- SwiftUI frontend (macOS/iOS)
- Vapor backend running on Raspberry Pi
- SQLite persistent storage
- Public key-based secure messaging
- Bridging real email accounts using SMTP and IMAP

### Secure Messaging
- Encrypted messages stored locally on a personal server
- Burn-after-read toggle
- Automatic device registration with public key upload
- Secure acknowledgment and deletion endpoints

### Standard Email Support
- SMTP send with `SwiftSMTP` (no CocoaPods)
- IMAP header fetching using native TCP stream handling
- Account management with in-app UI for email/password setup
- Mailboxes filtered by `accountTag` to prevent cross-account overlap

### User Interface
- Inbox, Sent, and Trash folders
- Message composition with toggle for secure/SMTP mode
- Visual message tags (burnable, acknowledged)
- Settings view for mail account credential management

---

## Project Structure

### Frontend Components
- `EncryptedMail.swift`: Unified model for secure + IMAP mail
- `MailAccount.swift`: Account model for SMTP/IMAP login
- `MailAccountStore.swift`: Observable store for linked accounts
- `SMTPService.swift`: Sends email using SwiftSMTP
- `RawIMAPClient.swift`: Handles native TCP connection and parsing for IMAP
- `IMAPToSecureBridge.swift`: Maps `IMAPMessage` to `EncryptedMail`
- `InboxView.swift`, `SendMailView.swift`, `SettingsView.swift`: Key views

### Backend Components (Vapor)
- `EncryptedMail` Fluent model with optional `accountTag`
- RESTful routes:
  - `POST /sendMail`
  - `GET /mailbox/:recipient?accountTag=`
  - `POST /checkDeviceExists`
  - `POST /registerDevice`
  - `POST /acknowledge/:id`
  - `DELETE /mail/:id`

---

## Setup Instructions

### Frontend (macOS)
1. Clone the repo and open `MailClient.xcodeproj`
2. Install `SwiftSMTP` via Swift Package Manager
3. Build and run the app
4. Navigate to Settings and add an email + app password

### Backend (Raspberry Pi)
1. Install Swift (`swiftly` recommended)
2. Navigate to `MailBackend/`
3. Run:
   ```bash
   swift run Run migrate
   swift run
   ```
4. Ensure port `8080` is exposed or port-forwarded if accessing remotely

---

## API Reference

### Send Secure Mail
```http
POST /sendMail
```
```json
{
  "sender": "device-id",
  "recipient": "device-id",
  "subject": "Test",
  "ciphertext": "...",
  "signature": "...",
  "burnAfterRead": true,
  "accountTag": "you@gmail.com"
}
```

### Fetch Inbox
```http
GET /mailbox/:recipient?accountTag=email@example.com
```
Returns filtered inbox for that account.

---

## Roadmap
- IMAP full body parsing
- Local caching + offline support
- OAuth2 login for Gmail/Outlook
- Background mail syncing
- Attachment support

---

## Security Notes
- SMTP credentials are held only in memory during session
- End-to-end encryption is implemented using asymmetric cryptography
- Messages are tagged and segmented by account to avoid leaks

---

## License
This project is intended for personal use and educational exploration.

---

## Author
Michael Danylchuk  
Electrical Engineering, SJSU  
