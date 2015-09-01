//
//  GraphViewController.swift
//  Calculator
//
//  Created by Caroline Liu on 2015-08-26.
//  Copyright (c) 2015 Caroline Liu. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController, GraphViewDataSource {
    
    @IBOutlet weak var graphView: GraphView! {
        didSet {
            graphView.dataSource = self
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(target: graphView, action: "scale:") )
        }
    }
    
    @IBAction func reposition(gesture: UITapGestureRecognizer) {
        switch gesture.state {
        case .Ended: fallthrough
        case .Changed:
            let location = gesture.locationInView(view)
            graphView.center = CGPoint(x: location.x, y: location.y )
        default: break
        }
    }
    
    @IBAction func move(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Ended: fallthrough
        case .Changed:
            let translation = gesture.translationInView(graphView)
            graphView.center = CGPoint(x:graphView.center.x + translation.x,
                y:graphView.center.y + translation.y)
        default: break
        }
        gesture.setTranslation(CGPointZero, inView: self.view)
    }
    
    /* the Model
    */
    var brain: CalculatorBrain? {
        didSet {
            updateUI()
        }
    }
 
    private func updateUI() {
        graphView?.setNeedsDisplay()
    }
    
    /*
    interpret the model for the view
    walk through all values in the range of X that are currently in the view
    replace the M value for each X to get the Y value
    */
    func pointsForGraph(sender: GraphView) -> [CGPoint] {
        var points = [CGPoint]()
        for var x = sender.bounds.minX; x <= sender.bounds.maxX; x++ {
            // need to re-calculate x given the bounds should be within an equal range of -x to +x
            var xval = (x - sender.center.x) / sender.scale
            brain?.variableValues["M"] = Double(xval)
            // TODO: When the graphView gets manipulated by a gesture we may hav to re-calculate this?
            if let result = brain?.evaluate() {
                var yval = CGFloat(result)
                points.append(CGPoint(x: xval, y: yval))
            }
        }
        return points
    }
}
