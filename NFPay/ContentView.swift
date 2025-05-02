import SwiftUI
import UserNotifications

private func registerNotificationActions() {
    let approve = UNNotificationAction(identifier: "APPROVE_ACTION",
                                       title: "Approve",
                                       options: [.authenticationRequired])

    let reject = UNNotificationAction(identifier: "REJECT_ACTION",
                                      title: "Reject",
                                      options: [.destructive])

    let remind = UNNotificationAction(identifier: "REMIND_ACTION",
                                      title: "Remind Me Later",
                                      options: [])

    let category = UNNotificationCategory(identifier: "TRANSFER_REQUEST_CATEGORY",
                                          actions: [approve, reject, remind],
                                          intentIdentifiers: [],
                                          options: [])

    UNUserNotificationCenter.current().setNotificationCategories([category])
}


struct ContentView: View {
    @State private var nfcReader = NFCReader()

    init() {
        requestNotificationPermission()
        registerNotificationActions()
    }

    var body: some View {
        VStack(spacing: 20) {
            Button("Receive Money") {
                sendMoneyReceivedNotification()
            }
            .buttonStyle(.bordered)

            Button("Approve Transfer Request") {
                sendTransferRequestNotification()
            }
            .buttonStyle(.bordered)

            Button("Scan NFPay Tag") {
                nfcReader.beginScanning()
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("✅ Notification permission granted")
            } else {
                print("❌ Notification permission denied")
            }
        }
    }

    private func sendMoneyReceivedNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Money Received"
        content.body = "£10 Received from Ishan"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString,
                                            content: content,
                                            trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending notification: \(error.localizedDescription)")
            }
        }
    }

    private func sendTransferRequestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Transfer Approval Needed"
        content.body = "Do you approve sending £10 to Ayman El Amrani?"
        content.sound = .default
        content.categoryIdentifier = "TRANSFER_REQUEST_CATEGORY"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString,
                                            content: content,
                                            trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending approval notification: \(error.localizedDescription)")
            }
        }
    }

}


import CoreNFC

class NFCReader: NSObject, NFCNDEFReaderSessionDelegate {
    private var session: NFCNDEFReaderSession?
    private let knownUID = "04A224B61A6480" // Replace with your tag's UID (uppercase, no colons)

    func beginScanning() {
        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        session?.alertMessage = "Hold your iPhone near the tag."
        session?.begin()
    }

    func readerSession(_ session: NFCNDEFReaderSession,
                       didDetectNDEFs messages: [NFCNDEFMessage]) {
        // Optional: handle NDEF data here
    }

    func readerSession(_ session: NFCNDEFReaderSession,
                       didInvalidateWithError error: Error) {

        print("⚠️ NFC session invalidated: \(error.localizedDescription)")

        DispatchQueue.main.async {
            self.triggerNotification()
        }
    }

    func readerSession(_ session: NFCNDEFReaderSession,
                       didDetect tags: [NFCNDEFTag]) {
        guard let tag = tags.first else { return }

        session.connect(to: tag) { error in
            if let error = error {
                print("❌ Error connecting to tag: \(error.localizedDescription)")
                session.invalidate()
                return
            }

            tag.queryNDEFStatus { status, _, error in
                guard error == nil else {
                    print("❌ Error querying tag: \(error!.localizedDescription)")
                    session.invalidate()
                    return
                }

                if let miFareTag = tag as? NFCMiFareTag {
                    let uid = miFareTag.identifier.map { String(format: "%02X", $0) }.joined()
                    print("🔎 Scanned UID: \(uid)")

                    if uid == self.knownUID {
                        self.triggerNotification()
                    } else {
                        print("🔐 Unknown tag UID: \(uid)")
                    }
                }

                session.invalidate()
            }
        }
    }

    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
        print("✅ NFC session became active.")
    }

    private func triggerNotification() {
        let content = UNMutableNotificationContent()
        content.title = "NFPay Tag Detected"
        content.body = "Open the app to send or request money to Ayman"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString,
                                            content: content,
                                            trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }
}

