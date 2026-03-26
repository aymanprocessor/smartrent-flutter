import Flutter
import UIKit
// Import Google Maps SDK to provide API key at startup
import GoogleMaps
import FirebaseCore

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Configure Firebase
    FirebaseApp.configure()
    
    // Provide Google Maps API key from Info.plist if present
    if let gmsKey = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String {
      if gmsKey != "AIzaSyDBtOCLLOaWvNjc5WPOQjBbHkSGSy3Y-9k" {
        GMSServices.provideAPIKey(gmsKey)
      }
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
