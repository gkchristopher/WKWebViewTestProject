//
//  ViewController.swift
//  WebViewCookiesSyncIssue
//
//  Created by Moore, Christopher - Christopher on 6/6/19.
//  Copyright © 2019 Moore, Christopher. All rights reserved.
//

import UIKit
import WebKit

enum CookieError: Error {
    case notFound
}

class ViewController: UIViewController {

    var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        webView = WKWebView(frame: view.bounds)

        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            view.bottomAnchor.constraint(equalTo: webView.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: webView.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        setCookie {
            self.getCookie(with: "test", completion: { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success( _):
                        self.webView.load(URLRequest(url: URL(string: "https://emojipedia-us.s3.dualstack.us-west-1.amazonaws.com/thumbs/240/apple/198/grinning-face_1f600.png")!))
                    case .failure( _):
                        self.webView.load(URLRequest(url: URL(string: "https://emojipedia-us.s3.dualstack.us-west-1.amazonaws.com/thumbs/240/apple/198/disappointed-face_1f61e.png")!))
                    }
                }
            })
        }
    }

    private func setCookie(completion: @escaping () -> Void) {
        if let configuration = webView?.configuration {
            let properties = [HTTPCookiePropertyKey.name: "test",
                              HTTPCookiePropertyKey.value: "1234",
                              HTTPCookiePropertyKey.domain: "http://.example.com",
                              HTTPCookiePropertyKey.path: "/",
                              HTTPCookiePropertyKey.originURL: "www.example.com"
                              ]
            let cookie = HTTPCookie(properties: properties)!
            configuration.websiteDataStore.httpCookieStore.setCookie(cookie) {
                completion()
            }
        }
    }

    private func getCookie(with name: String, completion: @escaping (Result<HTTPCookie, CookieError>) -> Void) {
        if let configuration = webView?.configuration {
            configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
                if let foundCookie = cookies.first(where: { $0.name == name }) {
                    completion(.success(foundCookie))
                } else {
                    completion(.failure(.notFound))
                }
            }
        }
    }
}

