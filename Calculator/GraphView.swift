//
//  GraphView.swift
//  Calculator
//
//  Created by Caroline Liu on 2015-08-26.
//  Copyright (c) 2015 Caroline Liu. All rights reserved.
//

import UIKit

protocol GraphViewDataSource: class {
    func pointsForGraph(sender: GraphView) -> [CGPoint]
}

@IBDesignable
class GraphView: UIView {

    @IBInspectable var scale: CGFloat = 50 { didSet{ setNeedsDisplay() } }
    
    var origin: CGPoint {
        return convertPoint(center, fromView: superview)
    }
    
    weak var dataSource: GraphViewDataSource?
    
    func scale(gesture: UIPinchGestureRecognizer) {
        if gesture.state == .Changed {
            scale *= gesture.scale
            gesture.scale = 1
        }
    }
    
    override func drawRect(rect: CGRect) {
        // TODO: Set the contentScaleFactor for AxesDrawer
        AxesDrawer().drawAxesInRect(self.bounds, origin: origin, pointsPerUnit: scale)
        let points = dataSource?.pointsForGraph(self) ?? [CGPoint]()
        let path = UIBezierPath()
        path.lineWidth = 0.5
        var drawing = false
        for point in points {
            var pointToDraw = CGPoint(x: (bounds.midX + (point.x * scale)), y: bounds.midY - (point.y * scale))
            
            // TODO: Handle discountinuous graphs
            if drawing {
                path.addLineToPoint(pointToDraw)
                println("ADDITIONAL POINT: \(pointToDraw.x) \(pointToDraw.y)")
            } else {
                path.moveToPoint(pointToDraw)
                println("POINT X: \(point.x)")
                println("INNITIAL POINT: \(pointToDraw.x) \(pointToDraw.y)")
                drawing = true
            }
        }
        path.stroke()
    }

}
