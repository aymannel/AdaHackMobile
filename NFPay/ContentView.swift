import SwiftUI
import UserNotifications

struct ContentView: View {

    init() {
        requestNotificationPermission()
    }

    var body: some View {
        VStack(spacing: 20) {
            Button("Receive Money") {
                sendMoneyReceivedNotification()
            }
            .buttonStyle(.bordered)

            Button("Approve Transfer Request") {
                // Action
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

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString,
                                            content: content,
                                            trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending notification: \(error.localizedDescription)")
            }
        }
    }
}
