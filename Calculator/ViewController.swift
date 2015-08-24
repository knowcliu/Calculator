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
    
    @IBOutlet weak var history: UILabel!

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
    
    @IBAction func changeSign() {
        if let i = display.text?.rangeOfString("-")?.startIndex {
            display.text?.removeAtIndex(i)
        } else {
            display.text = "-" + display.text!
        }

        if !userIsInTheMiddleOfTypingANumber {
            enter()
        }
    }
    
    @IBAction func enterPi(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        if let constant = sender.currentTitle {
            if let result = brain.pushConstant(constant) {
                displayValue = result
            } else {
                displayValue = 0
            }
        }
        userIsInTheMiddleOfTypingANumber = false
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
            if let result = NSNumberFormatter().numberFromString(display.text!)?.doubleValue {
                return result
            }
            return nil
        }
        
        set{
            userIsInTheMiddleOfTypingANumber = false

            display.text = (newValue == nil) ? " " : "\(newValue)"
            history.text = brain.description
        }
    }
}

