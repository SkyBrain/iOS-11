//
//  DocumentViewController.swift
//  DocumentBrowserApp
//
//  Created by Sampath on 7/24/17.
//  Copyright © 2017 SKY. All rights reserved.
//

import UIKit
import WebKit

class DocumentViewController: UIViewController {
    
    @IBOutlet weak var documentNameLabel: UILabel!
    
    var document: UIDocument?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Access the document
        document?.open(completionHandler: {[weak self] (success) in
            if success {
                // Display the content of the document, e.g.:
                self?.documentNameLabel.text = self?.document?.fileURL.lastPathComponent
                let data = try! Data(contentsOf: (self?.document?.fileURL)!)
                let webView = WKWebView(frame: CGRect(x:20,y:20,width:(self?.view.frame.size.width)!-40, height:(self?.view.frame.size.height)!-40))
                webView.load(data, mimeType: "application/pdf", characterEncodingName:"", baseURL: (self?.document?.fileURL)!)
                self?.view.addSubview(webView)
            } else {
                // Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
            }
        })
    }
    
    @IBAction func dismissDocumentViewController() {
        dismiss(animated: true) {
            self.document?.close(completionHandler: nil)
        }
    }
}
