import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)
    
    // Set up our custom method channel
    setupWindowControlChannel(flutterViewController: flutterViewController)

    super.awakeFromNib()
  }
  
  private func setupWindowControlChannel(flutterViewController: FlutterViewController) {
    let channel = FlutterMethodChannel(
      name: "ghost_layer/window_control",
      binaryMessenger: flutterViewController.engine.binaryMessenger
    )
    
    print("MainFlutterWindow: Method channel 'ghost_layer/window_control' created")

    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else {
        print("MainFlutterWindow: Window reference lost for method \(call.method)")
        result(FlutterError(code: "no_window", message: "Window reference lost", details: nil))
        return
      }

      print("MainFlutterWindow: Handling method \(call.method)")

      switch call.method {
      case "setAlwaysOnTop":
        guard let args = call.arguments as? [String: Any],
              let enabled = args["enabled"] as? Bool
        else {
          result(FlutterError(code: "bad_args", message: "Missing enabled", details: nil))
          return
        }
        if let levelInt = (args["level"] as? NSNumber)?.intValue {
          // Map simple levels if provided (0: normal, 1: statusBar)
          if enabled {
            self.level = (levelInt >= 1) ? .statusBar : .floating
          } else {
            self.level = .normal
          }
        } else {
          self.level = enabled ? .statusBar : .normal
        }
        print("MainFlutterWindow: setAlwaysOnTop enabled=\(enabled)")
        result(nil)

      case "setIgnoresMouseEvents":
        guard let args = call.arguments as? [String: Any],
              let enabled = args["enabled"] as? Bool
        else {
          result(FlutterError(code: "bad_args", message: "Missing enabled", details: nil))
          return
        }
        self.ignoresMouseEvents = enabled
        print("MainFlutterWindow: setIgnoresMouseEvents enabled=\(enabled)")
        result(nil)

      case "setSharingTypeNone":
        guard let args = call.arguments as? [String: Any],
              let enabled = args["enabled"] as? Bool
        else {
          result(FlutterError(code: "bad_args", message: "Missing enabled", details: nil))
          return
        }
        if #available(macOS 10.13, *) {
          self.sharingType = enabled ? .none : .readOnly   // .none hides from many capture APIs
          print("MainFlutterWindow: setSharingTypeNone enabled=\(enabled)")
          result(nil)
        } else {
          result(FlutterError(code: "unsupported", message: "Requires macOS 10.13+", details: nil))
        }

      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
