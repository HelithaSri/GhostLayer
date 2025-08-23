import Cocoa
import FlutterMacOS

public class WindowControlPlugin: NSObject, FlutterPlugin {
    private var flutterWindow: NSWindow?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "ghost_layer/window_control", binaryMessenger: registrar.messenger)
        let instance = WindowControlPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        // Get the Flutter window reference - try multiple ways
        if let window = registrar.view?.window {
            instance.flutterWindow = window
            print("WindowControlPlugin: Got window from registrar.view")
        } else if let mainWindow = NSApplication.shared.windows.first {
            instance.flutterWindow = mainWindow
            print("WindowControlPlugin: Got window from NSApplication.shared.windows")
        } else {
            print("WindowControlPlugin: No window found during registration")
        }
        
        print("WindowControlPlugin: Successfully registered with channel ghost_layer/window_control")
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        // Try to get window dynamically if not set during registration
        var window = flutterWindow
        if window == nil {
            window = NSApplication.shared.windows.first
            flutterWindow = window
            print("WindowControlPlugin: Got window dynamically in handle method")
        }
        
        guard let window = window else {
            print("WindowControlPlugin: No window available for method \(call.method)")
            result(FlutterError(code: "NO_WINDOW", message: "Flutter window not found", details: nil))
            return
        }
        
        print("WindowControlPlugin: Handling method \(call.method)")
        
        switch call.method {
        case "setSharingTypeNone":
            setSharingTypeNone(window: window, arguments: call.arguments, result: result)
        case "setIgnoresMouseEvents":
            setIgnoresMouseEvents(window: window, arguments: call.arguments, result: result)
        case "setAlwaysOnTop":
            setAlwaysOnTop(window: window, arguments: call.arguments, result: result)
        case "getWindowInfo":
            getWindowInfo(window: window, result: result)
        case "setWindowOpacity":
            setWindowOpacity(window: window, arguments: call.arguments, result: result)
        case "setWindowLevel":
            setWindowLevel(window: window, arguments: call.arguments, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func setSharingTypeNone(window: NSWindow, arguments: Any?, result: @escaping FlutterResult) {
        guard let args = arguments as? [String: Any],
              let enabled = args["enabled"] as? Bool else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for setSharingTypeNone", details: nil))
            return
        }
        
        DispatchQueue.main.async {
            if enabled {
                window.sharingType = .none
            } else {
                window.sharingType = .readOnly
            }
            result(true)
        }
    }
    
    private func setIgnoresMouseEvents(window: NSWindow, arguments: Any?, result: @escaping FlutterResult) {
        guard let args = arguments as? [String: Any],
              let enabled = args["enabled"] as? Bool else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for setIgnoresMouseEvents", details: nil))
            return
        }
        
        DispatchQueue.main.async {
            window.ignoresMouseEvents = enabled
            result(true)
        }
    }
    
    private func setAlwaysOnTop(window: NSWindow, arguments: Any?, result: @escaping FlutterResult) {
        guard let args = arguments as? [String: Any],
              let enabled = args["enabled"] as? Bool else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for setAlwaysOnTop", details: nil))
            return
        }
        
        let level = args["level"] as? Int
        
        DispatchQueue.main.async {
            if enabled {
                let windowLevel: NSWindow.Level
                if let levelValue = level {
                    switch levelValue {
                    case 1:
                        windowLevel = .floating
                    case 2:
                        windowLevel = .statusBar
                    case 3:
                        windowLevel = .modalPanel
                    case 4:
                        windowLevel = .popUpMenu
                    case 5:
                        windowLevel = .screenSaver
                    default:
                        windowLevel = .floating
                    }
                } else {
                    windowLevel = .floating
                }
                window.level = windowLevel
            } else {
                window.level = .normal
            }
            result(true)
        }
    }
    
    private func getWindowInfo(window: NSWindow, result: @escaping FlutterResult) {
        let info: [String: Any] = [
            "isAlwaysOnTop": window.level != .normal,
            "ignoresMouseEvents": window.ignoresMouseEvents,
            "sharingType": window.sharingType == .none ? "none" : "readOnly",
            "opacity": window.alphaValue,
            "level": window.level.rawValue,
            "frame": [
                "x": window.frame.origin.x,
                "y": window.frame.origin.y,
                "width": window.frame.size.width,
                "height": window.frame.size.height
            ]
        ]
        result(info)
    }
    
    private func setWindowOpacity(window: NSWindow, arguments: Any?, result: @escaping FlutterResult) {
        guard let args = arguments as? [String: Any],
              let opacity = args["opacity"] as? Double else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for setWindowOpacity", details: nil))
            return
        }
        
        DispatchQueue.main.async {
            window.alphaValue = CGFloat(max(0.0, min(1.0, opacity)))
            result(true)
        }
    }
    
    private func setWindowLevel(window: NSWindow, arguments: Any?, result: @escaping FlutterResult) {
        guard let args = arguments as? [String: Any],
              let level = args["level"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for setWindowLevel", details: nil))
            return
        }
        
        DispatchQueue.main.async {
            window.level = NSWindow.Level(rawValue: level)
            result(true)
        }
    }
}
