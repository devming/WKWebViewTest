//
//  ViewController.swift
//  WKWebViewTest
//
//  Created by devming on 2020/11/25.
//

import UIKit
import WebKit

class ViewController: UIViewController {
    
    var webView: WKWebView!
    let doStuffMessageHandlerName = "doStuffMessageHandler"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemPink
        
//        let pref = WKPreferences()
//        pref.javaScriptEnabled = false
//        pref.javaScriptCanOpenWindowsAutomatically = true
//        let webPref = WKWebpagePreferences()
//        webPref.allowsContentJavaScript = false
//        webPref.preferredContentMode = .mobile
        
        let configuration = WKWebViewConfiguration()
//        configuration.preferences = pref
//        configuration.defaultWebpagePreferences = webPref
        configuration.userContentController.add(self, name: doStuffMessageHandlerName)
        let rect = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - 100)
        
        webView = WKWebView(frame: rect, configuration: configuration)
        view.addSubview(webView)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.configuration.websiteDataStore.httpCookieStore.add(self)
        
        if let url = Bundle.main.url(forResource: "index", withExtension: "html") {
            let request = URLRequest(url: url)
            let naverRequest = URLRequest(url: URL(string: "https://www.google.com")!)
            /// 웹에서 사용한 쿠키를 알아볼때 사용함?
//            webView.addObserver(self, forKeyPath: "URL", options: [.new, .old], context: nil)

            webView.load(naverRequest)
//            webView.load(request)
        }
        let setbtn = UIButton(frame: CGRect(x: 20, y: view.frame.height - 100, width: 160, height: 80))
        setbtn.setTitle("Set COokie", for: .normal)
        setbtn.backgroundColor = .blue
        view.addSubview(setbtn)
        setbtn.addTarget(self, action: #selector(setCookieButtonTapped), for: .touchUpInside)
        
        let getbtn = UIButton(frame: CGRect(x: 200, y: view.frame.height - 100, width: 160, height: 80))
        getbtn.setTitle("Get COokie", for: .normal)
        getbtn.backgroundColor = .blue
        view.addSubview(getbtn)
        getbtn.addTarget(self, action: #selector(getCookieButtonTapped), for: .touchUpInside)
    }

    func doStuff(param1: String, param2: String) {
        print("param1: \(param1)")
        print("param2: \(param2)")
    }
    
    @objc func setCookieButtonTapped(_ sender: UIButton) {
        let properties: [HTTPCookiePropertyKey : Any] = [HTTPCookiePropertyKey.domain: ".test.co.kr",
                                                         HTTPCookiePropertyKey.name: "TEST",
                                                         HTTPCookiePropertyKey.path: "/",
                                                         HTTPCookiePropertyKey.maximumAge: 60,
                                                         HTTPCookiePropertyKey.value: "TEST"]
        let cookie = HTTPCookie(properties: properties)!
        
        webView.configuration.websiteDataStore.httpCookieStore.setCookie(cookie) {
            print("쿠키 등록 완료 - \(cookie.value)")
        }
    }
    @objc func getCookieButtonTapped(_ sender: UIButton) {
        webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
            cookies.enumerated().forEach { cookie in
                print("\(cookie.offset): \(cookie.element)")
            }
        }
    }

//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//
//        if let newValue = change?[.newKey] as? Int, let oldValue = change?[.oldKey] as? Int, newValue != oldValue {
//
//            print("NEW",change?[.newKey])
//        } else {
//            print("OLD",change?[.oldKey])
//
//        }
//
////        webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
////            cookies.enumerated().forEach { cookie in
////                print("\(cookie.offset): \(cookie.element)")
////            }
////        }
//    }
    
}

extension ViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == doStuffMessageHandlerName {
            guard let dict = message.body as? [String: AnyObject],
                  let param1 = dict["param1"] as? String,
                  let param2 = dict["param2"] as? String else {
                return
            }
            
            doStuff(param1: param1, param2: param2)
        }
    }
}

extension ViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
//        return WKWebView(frame: webView.frame, configuration: webView.configuration)
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
    
}

extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
//        preferences.allowsContentJavaScript = false
        preferences.preferredContentMode = .mobile
        decisionHandler(.allow, preferences)
    }
}

extension ViewController: WKHTTPCookieStoreObserver {
    func cookiesDidChange(in cookieStore: WKHTTPCookieStore) {
        cookieStore.getAllCookies { cookies in
            cookies.enumerated().forEach { cookie in
                print("\(cookie.offset): \(cookie.element)")
            }
        }
    }
}
