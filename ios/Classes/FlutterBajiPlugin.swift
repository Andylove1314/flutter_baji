import Flutter
import UIKit

public class FlutterBajiPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_baji", binaryMessenger: registrar.messenger())
        let instance = FlutterBajiPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        case "saveImageWithDpi":
            if let args = call.arguments as? [String: Any],
               let imagePath = args["imagePath"] as? String {
                
                guard let image = UIImage(contentsOfFile: imagePath),
                      let name = args["name"] as? String else {
                    result(FlutterError(code: "INVALID_IMAGE",
                                      message: "Could not load image",
                                      details: nil))
                    return
                }
                
                let dpi = args["dpi"] as? Int ?? 300
                let isJpg = args["isJpg"] as? Bool ?? true
                if let savedPath = ImageDpiUtil.saveImageWithDpi(image, name: name, dpi: dpi, isJpg: isJpg) {
                    result(savedPath)
                } else {
                    result(FlutterError(code: "SAVE_ERROR",
                                      message: "Failed to save image",
                                      details: nil))
                }
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS",
                                  message: "Missing required arguments",
                                  details: nil))
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
