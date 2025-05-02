import SwiftUI

@main
struct NFPayApp: App {
    // Connect AppDelegate to the SwiftUI app
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
