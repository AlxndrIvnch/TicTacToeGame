//
//  ViewController.swift
//  hackingwithswift4
//
//  Created by Aleksandr on 31.05.2022.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate {

    @IBOutlet var webView: WKWebView!
    var progressView: UIProgressView!
    
    var websites = [String]()
    var firsWebSite: String!
    var progressObservation: NSKeyValueObservation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Open", style: .plain, target: self, action: #selector(openTapped))
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload))
        
        progressView = UIProgressView(progressViewStyle: .default)
//        progressView.sizeToFit()
        let progress = UIBarButtonItem(customView: progressView)
        
        let chevronLeft = UIImage(systemName: "chevron.left")
        let chevronRight = UIImage(systemName: "chevron.right")
        let forward = UIBarButtonItem(image: chevronRight, style: .plain, target: webView, action: #selector(webView.goForward))
        let back = UIBarButtonItem(image: chevronLeft, style: .plain, target: webView, action: #selector(webView.goBack))
    
        toolbarItems = [back, spacer, forward, spacer, progress, spacer, refresh]
        navigationController?.isToolbarHidden = false
        
        
        guard let url = URL(string: "https://" + firsWebSite) else {
            navigationController?.popViewController(animated: true)
            return
        }
        let request = URLRequest(url: url)
        webView.load(request)
        canGoBackForward()
        
        progressObservation = observe(\ViewController.webView?.estimatedProgress, options: .new) { vc, change in
            guard let updatedprogress = change.newValue as? Double else { return }
            self.progressView.progress = Float(updatedprogress)
            if updatedprogress == 1 {
                self.progressView.isHidden = true
            } else {
                self.progressView.isHidden = false
            }
        }
//        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
     
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print(progressView.progress)
        if progressView.progress == 0.0 {
            navigationController?.popViewController(animated: true)
        }
    }
    
    func canGoBackForward() {
        guard let items = toolbarItems else { return }
            items[2].isEnabled = webView.canGoForward
            items[0].isEnabled = webView.canGoBack
    }
    
    @objc func openTapped() {

        let ac = UIAlertController(title: "Choose where to go...", message: nil, preferredStyle: .actionSheet)
        for website in websites {
            ac.addAction(UIAlertAction(title: website, style: .default, handler: openPage))
        }
 
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    func openPage(action: UIAlertAction) {
        guard let actionTitle = action.title else { return }
        guard let url = URL(string: "https://www." + actionTitle) else { return }
        webView.load(URLRequest(url: url))
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.url
        if let host = url?.host {
            for website in websites {
                if host.contains(website) {
                    decisionHandler(.allow)
                    return
                }
            }
            let ac = UIAlertController(title: "Can't go there", message: nil, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Ok", style: .default))
            present(ac, animated: true)
        }
        decisionHandler(.cancel)
    }

    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        canGoBackForward()
    }
    
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        if keyPath == "estimatedProgress" {
//            progressView.progress = Float(webView.estimatedProgress)
//        }
//    }
}

