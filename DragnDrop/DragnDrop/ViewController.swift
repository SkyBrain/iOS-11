//
//  ViewController.swift
//  DragnDrop
//
//  Created by Sampath on 7/9/17.
//  Copyright © 2017 Sam. All rights reserved.
//

import UIKit
import MobileCoreServices

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDragDelegate, UIDropInteractionDelegate, UIDragInteractionDelegate {
    
    @IBOutlet weak var postCard: UIImageView!
    @IBOutlet weak var colorSelection: UICollectionView!
    
    var image:UIImage?
    var topText = "Visit London"
    var topFontName = "Helvetica Neue"
    var topColor = UIColor.white
    var bottomText = "Home of Shrlock Holmes, Padding Bear, and James Bond"
    var bottomFontName = "Helvetica Neue"
    var bottomColor = UIColor.white
    
    var colors = [UIColor]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dragInteraction = UIDragInteraction(delegate: self)
        postCard.addInteraction(dragInteraction)
        
        colors += [.black, .gray, .white, .orange, .red, .magenta, .purple, .blue, .cyan, .green]
        colorSelection.dragDelegate = self
        for i in 0...9{
            for j in 0...9{
                let color = UIColor(hue: CGFloat(i)/10, saturation: CGFloat(j)/10, brightness: 1, alpha: 1)
                colors.append(color)
            }
        }
        
        postCard.isUserInteractionEnabled = true
        let dropInteraction = UIDropInteraction(delegate: self)
        postCard.addInteraction(dropInteraction)
        renderPostcard()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @available(iOS 6.0, *)
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        
        cell.backgroundColor = colors[indexPath.row]
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 5
        
        return cell
    }
    
    func renderPostcard() {
        
        //1 - define the total drawing space
        let drawRect = CGRect(x: 0, y: 0, width: 3000, height: 2400)
        
        //2 - define where to draw the top and bottom text
        let topTextRect = CGRect(x: 250, y: 200, width: 2500, height: 800)
        let bottomTextRect = CGRect(x: 250, y: 1800, width: 2500, height: 600)
        
        //3 - create UIFont instances out of the font names, providing fallbacks on failure
        let topFont = UIFont(name: topFontName, size: 350) ?? UIFont.systemFont(ofSize: 250)
        let bottomFont = UIFont(name: bottomFontName, size: 150) ?? UIFont.systemFont(ofSize: 100)
        
        //4 - create a centered paragraph style
        let centered = NSMutableParagraphStyle()
        centered.alignment = .center
        
        //5 - wrap that in attributed strings with the user's colors
        let topTextAttributes: [NSAttributedStringKey: Any]
            = [.foregroundColor: topColor, .font: topFont, .paragraphStyle: centered]
        let bottomTextAttributes: [NSAttributedStringKey: Any] = [.foregroundColor: bottomColor, .font: bottomFont, .paragraphStyle: centered]
        
        //6 - start rendering at the correct size
        let renderer = UIGraphicsImageRenderer(size: drawRect.size)
        
        postCard.image = renderer.image(actions:  { ctx in
            
            //fill the entire screen in gray
            UIColor.gray.set()
            ctx.fill(drawRect)
            
            //8 - draw the user's image at the top-left corner
            image?.draw(at: CGPoint(x: 0, y: 0))
            
            //9 - draw the top and bottom text
            topText.draw(in: topTextRect, withAttributes: topTextAttributes)
            bottomText.draw(in: bottomTextRect, withAttributes: bottomTextAttributes)
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let color = colors[indexPath.row]
        let provider = NSItemProvider(object: color)
        let item = UIDragItem(itemProvider: provider)
        
        return [item]
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: UIDropOperation.copy)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        let location = session.location(in: postCard)
        
        if session.hasItemsConforming(toTypeIdentifiers: [kUTTypePlainText as String]){
            session.loadObjects(ofClass: NSString.self, completion: { items in
                guard let string = items.first as? String else { return }
                
                if location.y < self.postCard.bounds.midY{
                    self.topFontName = string
                }
                else{
                    self.bottomFontName = string
                }
                self.renderPostcard()
            })
        }
        else if session.hasItemsConforming(toTypeIdentifiers: [kUTTypeImage as String]){
            session.loadObjects(ofClass: UIImage.self, completion: { items in
                guard let image = items.first as? UIImage else { return }
                
                self.image = image
                
                self.renderPostcard()
            })
        }
        else{
            session.loadObjects(ofClass: UIColor.self, completion: { items in
                guard let color = items.first as? UIColor else {return}
                
                if location.y < self.postCard.bounds.midY{
                    self.topColor = color
                }
                else{
                    self.bottomColor = color
                }
                self.renderPostcard()
            })
        }
    }
    
    @IBAction func changeText(_ sender: UITapGestureRecognizer) {
        
        let location = sender.location(in: postCard)
        
        let changeTop:Bool
        
        if location.y < self.postCard.bounds.midY{
            changeTop = true
        }
        else{
            changeTop = false
        }
        
        let ac = UIAlertController(title: "Change Text", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        
        ac.addTextField { textField in
            textField.placeholder = "Write what you want to say."
            
            if changeTop == true{
                textField.text = self.topText
            }
            else{
                textField.text = self.bottomText
            }
        }
        
        ac.addAction(UIAlertAction(title: "Change", style: UIAlertActionStyle.default, handler: { _ in
            guard let text = ac.textFields?[0].text else { return }
            
            if changeTop == true{
                self.topText = text
            }
            else{
                self.bottomText = text
            }
            self.renderPostcard()
        }))
        
        ac.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        self.present(ac, animated: true, completion: nil)
    }
    
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        guard let image = postCard.image else { return [] }
        
        let provider = NSItemProvider(object: image)
        
        return [UIDragItem(itemProvider: provider)]
    }
}
