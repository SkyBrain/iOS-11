//
//  ViewController.swift
//  PDFKit
//
//  Created by Sampath on 7/2/18.
//  Copyright © 2018 sky. All rights reserved.
//

import UIKit
import PDFKit
import SafariServices

class ViewController: UIViewController, PDFViewDelegate, PDFDocumentDelegate {
    
    let pdfView = PDFView()
    let textView = UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewMode = UISegmentedControl(items: ["PDF", "Text"])
        viewMode.addTarget(self, action: #selector(changeViewMode), for: .valueChanged)
        viewMode.selectedSegmentIndex = 0
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: viewMode)
        navigationItem.rightBarButtonItem?.width = 150
        
        pdfView.delegate = self
        view.addSubview(pdfView)
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        pdfView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        pdfView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        pdfView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        pdfView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textView)
        textView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        textView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        textView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        textView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        textView.isEditable = false
        textView.isHidden = true
        textView.textContainerInset = UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 20)
        
        //previous and next can go straight to the PDFView
        let previous = UIBarButtonItem(barButtonSystemItem: .rewind, target: pdfView, action: #selector(PDFView.goToPreviousPage(_:)))
        let next = UIBarButtonItem(barButtonSystemItem: .fastForward, target: pdfView, action: #selector(PDFView.goToNextPage(_:)))
        
        //search and share using our newly written methods
        let search = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(promptForSearch))
        let share = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareSelection))
        
        //assign all four to be our left bar button items
        navigationItem.leftBarButtonItems = [previous, next, search, share]
        
        pdfView.autoScales = true
    }
    
    func load(_ name: String) {
        //1 - convert the user-visible name to the filename
        let filename = name.replacingOccurrences(of: " ", with: "-").lowercased()
        
        //2 - find its path to the PDF in our bundle
        guard let path = Bundle.main.url(forResource: filename, withExtension: "pdf") else { return }
        
        //3 - load that path into a PDFDocument object
        if let document = PDFDocument(url: path) {
            
            //4 - assign it to our PDF view
            document.delegate = self
            pdfView.document = document
            
            //5 - force the PDF back to the cover page
            pdfView.goToFirstPage(nil)
            
            loadText()
            
            //6 - display the documents title if there's space
            if UIDevice.current.userInterfaceIdiom == .pad {
                
                title = name
            }
        }
    }
    
    @objc func promptForSearch() {
        //prepare an alert box
        let alert = UIAlertController(title: "Search", message: nil, preferredStyle: .alert)
        
        //give the user somewhere to type their search string
        alert.addTextField()
        alert.addAction(UIAlertAction(title: "Search", style: .default) { action in
            
            //pull out whatever they entered
            guard let searchText = alert.textFields?[0].text else { return }
            
            //find the fist match, starting from whatever (if anything) was highlighted previously
            guard let match = self.pdfView.document?.findString(searchText, fromSelection: self.pdfView.highlightedSelections?.first, withOptions: .caseInsensitive) else { return }
            
            //tell the PDF to jump to the match
            self.pdfView.highlightedSelections = [match]
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    @objc func shareSelection(sender: UIBarButtonItem) {
        guard let selection = pdfView.currentSelection?.attributedString else {
            //no text selection - show an error and exit
            let alert = UIAlertController(title: "Please select some text to share", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true)
            
            return
        }
        
        //send the selection off to be shared
        let vc = UIActivityViewController(activityItems: [selection], applicationActivities: nil)
        vc.popoverPresentationController?.barButtonItem = sender
        
        present(vc, animated: true)
    }
    
    func pdfViewWillClick(onLink sender: PDFView, with url: URL) {
        let vc = SFSafariViewController(url: url)
        vc.modalPresentationStyle = .formSheet
        present(vc, animated: true)
    }
    
    @objc func changeViewMode(segmentedControl: UISegmentedControl) {
        if segmentedControl.selectedSegmentIndex == 0 {
            pdfView.isHidden = false
            textView.isHidden = true
            
        } else {
            pdfView.isHidden = true
            textView.isHidden = false
            loadText()
        }
    }
    
    func loadText() {
        
        guard let pageCount = pdfView.document?.pageCount else { return }
        
        let documentContent = NSMutableAttributedString()
        
        for i in 1 ..< pageCount {
            
            guard let page = pdfView.document?.page(at: i) else { continue }
            guard let pageCount = page.attributedString else { continue }
            
            let spacer = NSAttributedString(string: "\n\n")
            documentContent.append(spacer)
            documentContent.append(pageCount)
        }
        
        let pattern = "www.hackingwithswift.com [0-9]{1,2}"
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSMakeRange(0, documentContent.string.utf16.count)
        
        if let matches = regex?.matches(in: documentContent.string, options: [], range: range) {
            for match in matches.reversed() {
                documentContent.replaceCharacters(in: match.range, with: "")
            }
        }
        
        textView.attributedText = documentContent
    }
    
    func classForPage() -> AnyClass {
        
        return SampleWaterMark.self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

