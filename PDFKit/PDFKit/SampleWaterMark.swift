//
//  SampleWaterMark.swift
//  PDFKitiOS
//
//  Created by Sampath on 7/2/18.
//  Copyright © 2018 sky. All rights reserved.
//

import UIKit
import PDFKit

class SampleWaterMark: PDFPage {
    override func draw(with box: PDFDisplayBox, to context: CGContext) {
        
        //draw the existing page first
        super.draw(with: box, to: context)
        
        //create our string of attributes
        let string: NSString = "SAMPLE CHAPTER"
        let attributes: [NSAttributedStringKey: Any] = [.foregroundColor: UIColor.red, .font: UIFont.boldSystemFont(ofSize: 32)]
        let stringSize = string.size(withAttributes: attributes)
        
        //save the state before we start moving and rotating
        UIGraphicsPushContext(context)
        context.saveGState()
        
        //figure out how much space we have for drawing
        let pageBounds = bounds(for: box)
        
        //move and flip the context, making it render the right way up
        context.translateBy(x: (pageBounds.size.width - stringSize.width) / 2, y: pageBounds.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        //draw our string slightly down from the top
        string.draw(at: CGPoint(x: 0, y: 55), withAttributes: attributes)
        
        //put everything back as it was
        context.restoreGState()
        UIGraphicsPopContext()
        
    }
}
