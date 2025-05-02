import UIKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // Set the notification centre delegate
        UNUserNotificationCenter.current().delegate = self
        return true
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
        default:
            urlString = nil
        }

        guard let urlStr = urlString, let url = URL(string: urlStr) else {
            print("❌ No valid endpoint for action: \(action)")
            completionHandler()
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
