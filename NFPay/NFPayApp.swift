import SwiftUI
import UserNotifications

@main
struct NFPayApp: App {
    // Set the notification delegate in the app initialiser
    init() {
        UNUserNotificationCenter.current().delegate = NotificationDelegate()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// Custom delegate to show notifications while the app is in the foreground
class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler:
                                @escaping (UNNotificationPresentationOptions) -> Void) {
        print("🔔 Notification received while app is in foreground")
        completionHandler([.banner, .sound]) // <-- Show it even when foregrounded
    }
}
