//
//  BestViewController.swift
//  knights25
//
//  Created by Vadim on 18. 9. 2025..
//

import UIKit
import WebKit


final class BestViewController: BaseViewController, WKNavigationDelegate {
    private let viewModel: BestViewModel
    private let webView = WKWebView(frame: .zero)
    private let progress = UIProgressView(progressViewStyle: .default)
    private var obsEstimated: NSKeyValueObservation?
    
    var onExitToPlay: (() -> Void)?
    private var didTriggerExit = false
    
    init(viewModel: BestViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        title = "Best Scores"
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        // Web view
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        
        // Progress
        progress.translatesAutoresizingMaskIntoConstraints = false
        progress.isHidden = true
        view.addSubview(progress)
        
        NSLayoutConstraint.activate([
            progress.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progress.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progress.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            webView.topAnchor.constraint(equalTo: progress.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        // KVO for progress
        obsEstimated = webView.observe(\.estimatedProgress, options: [.new]) { [weak self] _, change in
            guard let self = self, let p = change.newValue else { return }
            self.progress.isHidden = p >= 1.0
            self.progress.setProgress(Float(p), animated: true)
        }
        
        // Optional explicit button to go back to Play
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Play",
            style: .done,
            target: self,
            action: #selector(closeTapped)
        )
        
        // Toolbar: Reload & Share
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(reload)),
            UIBarButtonItem(barButtonSystemItem: .action,   target: self, action: #selector(share))
        ]
        
        // Pull to refresh
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(reload), for: .valueChanged)
        webView.scrollView.refreshControl = refresh
        
        load()
    }
    
    
    @objc private func closeTapped() {
        didTriggerExit = true
        onExitToPlay?()
        navigationController?.popViewController(animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent && !didTriggerExit {
            onExitToPlay?()
        }
    }
    
    
    
    @objc private func reload() {
        if webView.url != nil { webView.reload() } else { load() }
    }
    
    @objc private func share() {
        guard let url = webView.url ?? viewModel.url else { return }
        present(UIActivityViewController(activityItems: [url], applicationActivities: nil), animated: true)
    }
    
    private func load() {
        guard let url = viewModel.url else { return }
        progress.progress = 0; progress.isHidden = false
        webView.load(URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 20))
    }
    
    // WKNavigationDelegate (for refresh control + simple error UI)
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        progress.isHidden = true
        webView.scrollView.refreshControl?.endRefreshing()
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        progress.isHidden = true
        webView.scrollView.refreshControl?.endRefreshing()
        showError(error)
    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        progress.isHidden = true
        webView.scrollView.refreshControl?.endRefreshing()
        showError(error)
    }
    private func showError(_ error: Error) {
        let alert = UIAlertController(title: "Load Failed", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        alert.addAction(UIAlertAction(title: "Open in Safari", style: .default, handler: { _ in
            if let url = self.viewModel.url { UIApplication.shared.open(url) }
        }))
        present(alert, animated: true)
    }
}
