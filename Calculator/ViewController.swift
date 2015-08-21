//
//  ViewController.swift
//  Calculator
//
//  Created by Caroline Liu on 2015-08-18.
//  Copyright (c) 2015 Caroline Liu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var display: UILabel!
    
    var userIsInTheMiddleOfTypingANumber = false
    
    var brain = CalculatorBrain()
    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        
        if userIsInTheMiddleOfTypingANumber {
            display.text = display.text! + digit
        } else {
            display.text = digit
            userIsInTheMiddleOfTypingANumber = true
        }
        
    }
    
    @IBAction func clear() {
        userIsInTheMiddleOfTypingANumber = false
        brain.clear()
        displayValue = 0
    }
    
    @IBAction func decimalPoint() {
        if userIsInTheMiddleOfTypingANumber {
            if display.text?.rangeOfString(".") == nil {
                display.text = display.text! + "."
            }
        } else {
            display.text = "0."
            userIsInTheMiddleOfTypingANumber = true
        }
    }
    
    @IBAction func pi() {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        displayValue = M_PI
        enter()
    }
    
    @IBAction func operate(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        
        if let operation = sender.currentTitle {
            if let result = brain.performOperation(operation) {
                displayValue = result
            } else {
                displayValue = 0
            }
        }
    }
    
    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        if let result = brain.pushOperand(displayValue) {
            displayValue = result
        } else {
             displayValue = 0
        }
    }
    
    var displayValue: Double! {
        get{
            return NSNumberFormatter().numberFromString(display.text!)?.doubleValue
        }
        
        set{
            if newValue == nil {
                display.text = " "
            } else {
                display.text = "\(newValue)"
            }
            userIsInTheMiddleOfTypingANumber = false
        }
    }
    
}

