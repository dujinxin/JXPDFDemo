//
//  WebViewController.swift
//  PDFBrowseDemo
//
//  Created by 杜进新 on 2018/7/19.
//  Copyright © 2018年 dujinxin. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    
    var webView: WKWebView!
    
    lazy var processView: UIProgressView = {
        let process = UIProgressView()
        process.progressTintColor = UIColor.blue
        process.progress = 0.0
        return process
    }()
    var homeUrl: URL? {
        return URL(string: "http://devstreaming.apple.com/videos/wwdc/2016/201h1g4asm31ti2l9n1/201/201_internationalization_best_practices.pdf")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.title = self.webView.title;
        self.navigationController?.navigationBar.tintColor = .black
        
        
        let config = WKWebViewConfiguration()
        //初始化偏好设置属性：preferences
        let preferences = WKPreferences()
        config.preferences = preferences
        //The minimum font size in points default is 0
        config.preferences.minimumFontSize = 10
        //是否支持JavaScript
        config.preferences.javaScriptEnabled = true
        //不通过用户交互，是否可以打开窗口
        config.preferences.javaScriptCanOpenWindowsAutomatically = false
        //通过JS与webView内容交互
        let userContentController = WKUserContentController()
        config.userContentController = userContentController
        // 注入JS对象名称senderModel，当JS通过senderModel来调用时，我们可以在WKScriptMessageHandler代理中接收到
        //let web = WKWebView(frame: CGRect(), configuration: config)
        webView = WKWebView(frame: view.bounds, configuration: config)
        view.addSubview(webView)
        
        
        self.processView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 2)
        view.addSubview(self.processView)
        
        self.webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        self.webView.addObserver(self, forKeyPath: "title", options: .new, context: nil)
        self.webView.addObserver(self, forKeyPath: "URL", options: .new, context: nil)
        
        webView.uiDelegate = self
        webView.navigationDelegate = self
        
        
        if let url = homeUrl {
            self.webView.load(URLRequest(url: url))
        } else {
            let url = Bundle.main.url(forResource: "apple", withExtension: "pdf")
            self.webView.load(URLRequest(url: url!))
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //self.navigationController?.isNavigationBarHidden = false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "title" {
            //            if  self.webView.title == "首页" {
            //                self.navigationItem.leftBarButtonItem = nil
            //            }else {
            //                self.title = self.webView.title;
            //                self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "nav_back"), style: .plain, target: self, action: #selector(goback))
            //            }
        }else if keyPath == "estimatedProgress"{
            if
                let change = change,
                let processValue = change[NSKeyValueChangeKey.newKey],
                let process = processValue as? Float{
                
                self.processView.setProgress(process, animated: true)//动画有延时，所以要等动画结束再隐藏
                if process == 1.0 {
                    //perform(<#T##aSelector: Selector##Selector#>, with: <#T##Any?#>, afterDelay: <#T##TimeInterval#>)
                    DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.25, execute: {
                        self.processView.alpha = 0.0
                    })
                }
            }
        }else if keyPath == "URL"{
            guard
                let change = change,
                let value = change[NSKeyValueChangeKey.newKey],
                let url = value as? URL else{
                    return
            }
            print("webview.url = " + (webView.url?.absoluteString)!)
            print("url = " + url.absoluteString)
            
            if webView.url?.absoluteString == homeUrl?.absoluteString {
                //            self.navigationItem.leftBarButtonItem = nil
                print("首页")
                
            }else {
                //            self.title = self.webView.title;
                //            self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "nav_back"), style: .plain, target: self, action: #selector(goback))
                print("次级")
            }
        }
        
    }
    deinit {
        self.webView.removeObserver(self, forKeyPath: "title")
        self.webView.removeObserver(self, forKeyPath: "URL")
        self.webView.removeObserver(self, forKeyPath: "estimatedProgress")
        self.webView.configuration.userContentController.removeScriptMessageHandler(forName: "getParames")
        
    }
    @objc func goback() {
        if self.webView.canGoBack {
            self.webView.goBack()
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    @objc func loginStatus(notify:Notification) {
        print(notify)
        
        if let isSuccess = notify.object as? Bool,
            isSuccess == true,
            let url = homeUrl{
            
            self.webView.load(URLRequest(url: url))
            
        }
    }
}
extension WebViewController:WKUIDelegate{
    /*! @abstract Creates a new web view.
     @param webView The web view invoking the delegate method.
     @param configuration The configuration to use when creating the new web
     view.
     @param navigationAction The navigation action causing the new web view to
     be created.
     @param windowFeatures Window features requested by the webpage.
     @result A new web view or nil.
     @discussion The web view returned must be created with the specified configuration. WebKit will load the request in the returned web view.
     
     If you do not implement this method, the web view will cancel the navigation.
     */
    //    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
    //        return self.wkWebView
    //    }
    func webViewDidClose(_ webView: WKWebView) {
        print("close")
    }
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        print("alert")
        let alert = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .destructive, handler: { (action) in
            print("确定")
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (action) in
            print("取消")
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        print("confirm")
    }
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        print("textInput")
    }
    //实现该方法，可以弹出自定义视图
    @available(iOS 10.0, *)
    func webView(_ webView: WKWebView, shouldPreviewElement elementInfo: WKPreviewElementInfo) -> Bool {
        return true
    }
    //实现该方法，可以弹出自定义视图控制器
    @available(iOS 10.0, *)
    func webView(_ webView: WKWebView, previewingViewControllerForElement elementInfo: WKPreviewElementInfo, defaultActions previewActions: [WKPreviewActionItem]) -> UIViewController? {
        return nil
    }
    //实现该方法，关闭自定义视图控制器
    func webView(_ webView: WKWebView, commitPreviewingViewController previewingViewController: UIViewController) {
        
    }
}
extension WebViewController:WKNavigationDelegate{
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("start")
    }
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("commit")
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("finish")
        
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("fail:\(error.localizedDescription)")
    }
    
    //当webView的web内容进程被终止时调用。(iOS 9.0之后)
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        
    }
    //监听页面跳转的代理方法，分为：收到跳转与决定是否跳转两种
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
    }
    //收到服务器重定向时调用
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        
    }
    //当webView需要响应身份验证时调用(如需验证服务器证书)
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.performDefaultHandling, nil)
    }
    ////加载错误时调用
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        
    }
    
}
