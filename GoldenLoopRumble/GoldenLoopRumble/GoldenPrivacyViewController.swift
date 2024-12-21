//
//  GoldenPrivacyViewController.swift
//  GoldenLoopRumble
//
//  Created by jin fu on 2024/12/21.
//

import UIKit
@preconcurrency import WebKit

class GoldenPrivacyViewController: UIViewController, WKScriptMessageHandler, WKNavigationDelegate, WKUIDelegate {

    let goldenPrivacyUrl = "https://www.termsfeed.com/live/b1c3c5dd-b063-442e-a9e0-f6ebcb8e01f0"
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var goldenWebView: WKWebView!
    @IBOutlet weak var topCos: NSLayoutConstraint!
    @IBOutlet weak var bottomCos: NSLayoutConstraint!
    var backAction: (() -> Void)?
    var privacyData: [Any]?
    @objc var url: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.privacyData = UserDefaults.standard.array(forKey: UIViewController.goldenGetUserDefaultKey())
        initSubViews()
        initNavView()
        initWebView()
        startLoadWebView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let confData = privacyData, confData.count > 4 {
            let top = (confData[3] as? Int) ?? 0
            let bottom = (confData[4] as? Int) ?? 0
            
            if top > 0 {
                topCos.constant = view.safeAreaInsets.top
            }
            if bottom > 0 {
                bottomCos.constant = view.safeAreaInsets.bottom
            }
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait, .landscape]
    }
    
    @objc func backClick() {
        backAction?()
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - INIT
    private func initSubViews() {
        goldenWebView.scrollView.contentInsetAdjustmentBehavior = .never
        view.backgroundColor = .black
        goldenWebView.backgroundColor = .black
        goldenWebView.isOpaque = false
        goldenWebView.scrollView.backgroundColor = .black
        indicatorView.hidesWhenStopped = true
    }
    
    private func initNavView() {
        guard let url = url, !url.isEmpty else {
            goldenWebView.scrollView.contentInsetAdjustmentBehavior = .automatic
            return
        }
        
        navigationController?.navigationBar.tintColor = .systemBlue
        
        let image = UIImage(systemName: "xmark")
        let rightButton = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(backClick))
        navigationItem.rightBarButtonItem = rightButton
    }
    
    private func initWebView() {
        guard let confData = privacyData, confData.count > 7 else { return }
        
        let userContentC = goldenWebView.configuration.userContentController
        
        if let ty = confData[18] as? Int, ty == 1 || ty == 2 {
            if let trackStr = confData[5] as? String {
                let trackScript = WKUserScript(source: trackStr, injectionTime: .atDocumentStart, forMainFrameOnly: false)
                userContentC.addUserScript(trackScript)
            }
            
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
               let bundleId = Bundle.main.bundleIdentifier,
               let wgName = confData[7] as? String {
                let inPPStr = "window.\(wgName) = {name: '\(bundleId)', version: '\(version)'}"
                let inPPScript = WKUserScript(source: inPPStr, injectionTime: .atDocumentStart, forMainFrameOnly: false)
                userContentC.addUserScript(inPPScript)
            }
            
            if let messageHandlerName = confData[6] as? String {
                userContentC.add(self, name: messageHandlerName)
            }
        }
        
        else if let ty = confData[18] as? Int, ty == 3 {
            if let trackStr = confData[29] as? String {
                let trackScript = WKUserScript(source: trackStr, injectionTime: .atDocumentStart, forMainFrameOnly: false)
                userContentC.addUserScript(trackScript)
            }
            
            if let messageHandlerName = confData[6] as? String {
                userContentC.add(self, name: messageHandlerName)
            }
        }
        
        else {
            userContentC.add(self, name: confData[19] as? String ?? "")
        }
        
        goldenWebView.navigationDelegate = self
        goldenWebView.uiDelegate = self
    }
    
    
    private func startLoadWebView() {
        let urlStr = url ?? goldenPrivacyUrl
        guard let url = URL(string: urlStr) else { return }
        
        indicatorView.startAnimating()
        let request = URLRequest(url: url)
        goldenWebView.load(request)
    }
    
    private func goldenReloadWebViewData(_ adurl: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let storyboard = self.storyboard,
               let adView = storyboard.instantiateViewController(withIdentifier: "GoldenPrivacyViewController") as? GoldenPrivacyViewController {
                adView.url = adurl
                adView.backAction = { [weak self] in
                    let close = "window.closeGame();"
                    self?.goldenWebView.evaluateJavaScript(close, completionHandler: nil)
                }
                let nav = UINavigationController(rootViewController: adView)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - WKScriptMessageHandler
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let confData = privacyData, confData.count > 9 else { return }
        
        let name = message.name
        if name == (confData[6] as? String),
           let trackMessage = message.body as? [String: Any] {
            let tName = trackMessage["name"] as? String ?? ""
            let tData = trackMessage["data"] as? String ?? ""
            
            if let ty = confData[18] as? Int, ty == 1 {
                if let data = tData.data(using: .utf8) {
                    do {
                        if let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                            if tName != (confData[8] as? String) {
                                goldenSendEvent(tName, values: jsonObject)
                                return
                            }
                            if tName == (confData[9] as? String) {
                                return
                            }
                            if let adId = jsonObject["url"] as? String, !adId.isEmpty {
                                goldenReloadWebViewData(adId)
                            }
                        }
                    } catch {
                        goldenSendEvent(tName, values: [tName: data])
                    }
                } else {
                    goldenSendEvent(tName, values: [tName: tData])
                }
            } else if let ty = confData[18] as? Int, ty == 2 {
                goldenAfSendEvents(tName, paramsStr: tData)
            } else {
                if self.goldenLowercase(tName) == self.goldenLowercase(confData[28] as? String ?? "") {
                    if let url = URL(string: tData),
                       UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                } else {
                    goldenAfSendEvent(withName: tName, value: tData)
                }
            }
            
        } else if name == (confData[19] as? String) {
            if let messageBody = message.body as? String,
               let dic = goldenJsonToDic(withJsonString: messageBody) as? [String: Any],
               let evName = dic["funcName"] as? String,
               let evParams = dic["params"] as? String {
                
                if evName == (confData[20] as? String) {
                    if let uDic = goldenJsonToDic(withJsonString: evParams) as? [String: Any],
                       let urlStr = uDic["url"] as? String,
                       let url = URL(string: urlStr),
                       UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                } else if evName == (confData[21] as? String) {
                    goldenSendEvents(withParams: evParams)
                }
            }
        }
    }
    
    // MARK: - WKNavigationDelegate
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        DispatchQueue.main.async {
            self.indicatorView.stopAnimating()
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        DispatchQueue.main.async {
            self.indicatorView.stopAnimating()
        }
    }
    
    // MARK: - WKUIDelegate
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil, let url = navigationAction.request.url {
            UIApplication.shared.open(url)
        }
        return nil
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let authenticationMethod = challenge.protectionSpace.authenticationMethod
        if authenticationMethod == NSURLAuthenticationMethodServerTrust,
           let serverTrust = challenge.protectionSpace.serverTrust {
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        }
    }
    
}
