//
//  ImageGenerator.swift
//  YabaiIndicator
//
//  Created by Max Zhao on 29/12/2021.
//
import Foundation
import Cocoa
import SwiftUI

private func drawText(symbol: NSString, color: NSColor, size: CGSize) {
    let fontSize:CGFloat = 12

    let attrs:[NSAttributedString.Key : Any] = [.font: NSFont.systemFont(ofSize: fontSize), .foregroundColor: color]
    let boundingBox = symbol.size(withAttributes: attrs)
    let x:CGFloat = size.width / 2 - boundingBox.width / 2
    let y:CGFloat = size.height / 2 - boundingBox.height / 2
    symbol.draw(at: NSPoint(x: x, y: y), withAttributes: [.font: NSFont.systemFont(ofSize: fontSize), .foregroundColor: color])
}

func generateImage(symbol: NSString, active: Bool, visible: Bool, hasWindows: [Int]) -> NSImage {
    let size = CGSize(width: 24, height: 18)
    let cornerRadius:CGFloat = 6
    let canvas = NSRect(origin: CGPoint.zero, size: size)
    
    let image = NSImage(size: size)
    let strokeColor = NSColor.black
    
    if active {
        let imageFill = NSImage(size: size)
        let imageStroke = NSImage(size: size)

        imageFill.lockFocus()
        strokeColor.setFill()
        NSBezierPath(roundedRect: canvas, xRadius: cornerRadius, yRadius: cornerRadius).fill()
        imageFill.unlockFocus()
        imageStroke.lockFocus()
        drawText(symbol: NSString(string: symbol), color: strokeColor, size: size)
        imageStroke.unlockFocus()
        
        image.lockFocus()
        imageFill.draw(in: canvas, from: NSZeroRect, operation: .sourceOut, fraction: active ? 1.0 : 0.8)
        imageStroke.draw(in: canvas, from: NSZeroRect, operation: .destinationOut, fraction: active ? 1.0 : 0.8)
        image.unlockFocus()
    } else if visible {
        image.lockFocus()
        strokeColor.setStroke()
        let path = NSBezierPath(roundedRect: canvas.insetBy(dx: 0.5, dy: 0.5), xRadius: cornerRadius, yRadius: cornerRadius)
        path.stroke()
        drawText(symbol: symbol, color: strokeColor, size: size)
        image.unlockFocus()
    } else if !hasWindows.isEmpty {
        image.lockFocus()
        strokeColor.setStroke()
        drawText(symbol: NSString(format: "%@%@", "* ", symbol), color: strokeColor, size: size)
        image.unlockFocus()
    } else {
        image.lockFocus()
        strokeColor.setStroke()
        drawText(symbol: symbol, color: strokeColor, size: size)
        image.unlockFocus()
    }
    image.isTemplate = true
    return image
}
