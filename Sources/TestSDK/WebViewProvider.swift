import UIKit
import WebKit
import AVFoundation

public class WebViewProvider {

    private var webView: WKWebView!
    private var permissionsAllowed: Bool = false
    private let url: URL = URL(string: "https://mvc.t2m.kz/demos/echotest.html")!
    
    public init() {}

    public func loadPage() -> Bool {
        checkPermissions()
        
        if !permissionsAllowed {
            print("WebViewProvider error: permissions are not allowed")
            return false
        }
        
        let conf = WKWebViewConfiguration()
            
        if #available(iOS 14.0, *) {
            let preference = WKWebpagePreferences()
            preference.preferredContentMode = .mobile
            preference.allowsContentJavaScript = true
            
            conf.defaultWebpagePreferences = preference
            webView.load(URLRequest(url: url))
            
            print("WebViewProvider: webView has loaded")
            return true
        }
        else {
            webView.load(URLRequest(url: url))
            
            print("WebViewProvider: webView has loaded, but ios version is too low")
            return true
        }
//
//        print("WebViewProvider error: ios version problem")
//        return false
    }
    
    public func setWebView(webView: WKWebView) {
        self.webView = webView
        requestPermissions()
    }
    
    public func requestPermissions(completion: @escaping () -> Void) {
        let group = DispatchGroup()
        
        group.enter()
        AVCaptureDevice.requestAccess(for: .audio) {[weak self] granted in
            guard self != nil else {return}
            if(granted) {
                DispatchQueue.main.async {
//                    self.checkPermissions()
                    group.leave()
                }
            }
        }
        
        group.enter()
        AVCaptureDevice.requestAccess(for: .video) {[weak self] granted in
            guard self != nil else {return}
            if(granted) {
                DispatchQueue.main.async {
//                    self.checkPermissions()
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            self.checkPermissions()
            completion()
        }
    }
    
    public func requestPermissions() {
        AVCaptureDevice.requestAccess(for: .video) {[weak self] granted in
            guard let self = self else {return}
            if(granted) {
                DispatchQueue.main.async {
                    self.checkPermissions()
                }
            }
        }
        
        AVCaptureDevice.requestAccess(for: .audio) {[weak self] granted in
            guard let self = self else {return}
            if(granted) {
                DispatchQueue.main.async {
                    self.checkPermissions()
                }
            }
        }
    }
    
    public func checkPermissions() {
        let videoAuthorized = AVCaptureDevice.authorizationStatus(for: .video) == .authorized
        let audioAuthorized = AVCaptureDevice.authorizationStatus(for: .audio) == .authorized
        
        print("WebViewProvider: camera access granted - " + String(videoAuthorized))
        print("WebViewProvider: microphone access granted - " + String(audioAuthorized))
        
        if videoAuthorized && audioAuthorized {
            permissionsAllowed = true
        }
    }
}

    