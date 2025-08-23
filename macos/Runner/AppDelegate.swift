import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
    override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
    
    override func applicationDidFinishLaunching(_ notification: Notification) {
        super.applicationDidFinishLaunching(notification)
        
        print("AppDelegate: applicationDidFinishLaunching called")
        print("AppDelegate: mainFlutterWindow = \(String(describing: mainFlutterWindow))")
        
        // Try multiple ways to register the plugin
        if let controller = mainFlutterWindow?.contentViewController as? FlutterViewController {
            print("AppDelegate: Found FlutterViewController, registering WindowControlPlugin")
            let registrar = controller.registrar(forPlugin: "WindowControlPlugin")
            print("AppDelegate: Got registrar: \(registrar)")
            WindowControlPlugin.register(with: registrar)
            print("AppDelegate: WindowControlPlugin registration completed")
        } else {
            print("AppDelegate: ERROR - Could not find FlutterViewController")
            print("AppDelegate: mainFlutterWindow?.contentViewController = \(String(describing: mainFlutterWindow?.contentViewController))")
        }
        
        // Also try registering after a delay to ensure window is ready
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            print("AppDelegate: Attempting delayed plugin registration")
            if let controller = self.mainFlutterWindow?.contentViewController as? FlutterViewController {
                print("AppDelegate: Delayed registration - found FlutterViewController")
                WindowControlPlugin.register(with: controller.registrar(forPlugin: "WindowControlPlugin"))
                print("AppDelegate: Delayed WindowControlPlugin registration completed")
            } else {
                print("AppDelegate: Delayed registration - still no FlutterViewController")
            }
        }
    }
}
