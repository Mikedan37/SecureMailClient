# 📡 APIService (SecureMailClient)

This Swift service manages all client-side HTTP interactions with your Vapor backend for encrypted messaging. It handles device registration, message sending, mailbox access, and burn-on-read logic.

---

## 🔐 Device Identity

- Devices are uniquely identified by `DeviceUtils.deviceID`
- Each device must register a public key using:
  - `registerDevice(deviceID:publicKey:)`
- Device registration is checked automatically via:
  - `ensureDeviceIsRegistered(publicKey:)`

---

## 📬 Mailbox Endpoints

### `GET /mailbox/{deviceID}`  
Fetch all inbox messages for the current device.

```swift
func fetchInbox() async throws -> [EncryptedMail]

    •    Auto-resolves deviceID internally.
    •    Returns an array of EncryptedMail models from the inbox.


POST /sendEncryptedMail

Send a message encrypted for a specific recipient.

func sendMail(
  recipient: String,
  ciphertext: String,
  signature: String,
  burnAfterRead: Bool
) async throws

    •    Automatically sets sender to current device ID
    •    Encodes the body as:

{
  "sender": "<device-id>",
  "recipient": "<target-device-id>",
  "ciphertext": "<base64>",
  "signature": "<signature>",
  "burnAfterRead": true
}


POST /acknowledgeMail

Mark a message as read/acknowledged.

func acknowledgeMail(id: UUID) async throws

    •    Can also be triggered automatically on view:

func acknowledgeOnRead(for mail: EncryptedMail) async


DELETE /mailbox/{id}

Delete a specific message by ID.

func deleteMail(id: UUID) async throws



🔑 Public Key Management

GET /publicKey/{deviceID}

Fetch a device’s registered public key.

func getPublicKey(for deviceID: String) async throws -> String


🧪 Mock Data (for Testing)

func fetchSent(for recipient: String) async throws -> [EncryptedMail]
func fetchTrash(for recipient: String) async throws -> [EncryptedMail]

    •    These return static mock data for now and can be replaced with backend routes later.
    

🧱 Models

EncryptedMailPayload (used for sending)

struct EncryptedMailPayload: Codable {
    let sender: String
    let recipient: String
    let ciphertext: String
    let signature: String
    let burnAfterRead: Bool
}


🚀 Example Usage

let inbox = try await APIService.shared.fetchInbox()
try await APIService.shared.sendMail(
    recipient: "iphone-001",
    ciphertext: encryptedText,
    signature: signedText,
    burnAfterRead: true
)


📡 Base URL

Currently hardcoded to:

http://10.0.0.246:8080

Change this for production or configurable environments.


📌 Notes
    •    All endpoints use JSONEncoder/Decoder with ISO-8601 date support
    •    Error handling is minimal and should be extended in production
    •    Designed to interface directly with a Swift Vapor backend running on Raspberry Pi
