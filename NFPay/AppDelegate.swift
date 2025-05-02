import UIKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // Set the notification centre delegate
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    // Handle URL-based app opening (e.g. nfpay://amount-entry)
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {

        if url.scheme == "nfpay", url.host == "amount-entry" {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .launchAmountEntry, object: nil)
            }
            return true
        }

        return false
    }

    // Display notification banner while app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }

    // Handle action button taps from notification
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {

        let action = response.actionIdentifier
        let urlString: String?

        switch action {
        case "APPROVE_ACTION":
            urlString = "https://luckily-learning-elf.ngrok-free.app/approve"
        case "REJECT_ACTION":
            urlString = "https://luckily-learning-elf.ngrok-free.app/decline"
        case "REMIND_ACTION":
            urlString = "https://luckily-learning-elf.ngrok-free.app/defer"
        case UNNotificationDefaultActionIdentifier:
            // User tapped the notification (not a button)
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .launchAmountEntry, object: nil)
                completionHandler()
            }
            return
        default:
            urlString = nil
        }

        guard let urlStr = urlString, let url = URL(string: urlStr) else {
            print("❌ No valid endpoint for action: \(action)")
            DispatchQueue.main.async {
                completionHandler()
            }
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let task = URLSession.shared.dataTask(with: request) { _, _, error in
            if let error = error {
                print("❌ Error sending \(action): \(error.localizedDescription)")
            } else {
                print("✅ Successfully hit endpoint for \(action)")
            }

            // Must call on the main thread!
            DispatchQueue.main.async {
                completionHandler()
            }
        }
        task.resume()
    }
}

// Notification name used for routing to the amount entry screen
extension Notification.Name {
    static let launchAmountEntry = Notification.Name("launchAmountEntry")
}

