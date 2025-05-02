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

            Button("NFPay Tag Detected") {
                // Action
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
        content.body = "Do you approve sending £10 to Ishan?"
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
