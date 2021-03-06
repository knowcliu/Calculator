//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Caroline Liu on 2015-08-18.
//  Copyright (c) 2015 Caroline Liu. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    private enum Op: Printable {
        case Operand(Double)
        case Variable(String)
        case Constant(String)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .Variable(let variable):
                    return variable
                case .Constant(let symbol):
                    return symbol
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                }
            }
        }
    }
    
    private var opStack = [Op]()
    
    private var knownOps = [String: Op]()
    
    private var constantValues: Dictionary<String, Double!> = ["π": M_PI]

    var variableValues: Dictionary<String, Double!> = [:]

    init() {
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        learnOp(Op.BinaryOperation("×") { $1 * $0 })
        learnOp(Op.BinaryOperation("÷") { $1 / $0 })
        learnOp(Op.BinaryOperation("+") { $1 + $0 })
        learnOp(Op.BinaryOperation("−") { $1 - $0 })
        learnOp(Op.UnaryOperation("√") { sqrt($0) })
        learnOp(Op.UnaryOperation("sin") { sin($0) })
        learnOp(Op.UnaryOperation("cos") { cos($0) })
    }
    
    /*
    To reset the calculator program in the future or to pass it to another calculator.
    */
    var program: AnyObject {
        get {
            return opStack.map { $0.description }
        }
        set {
            if let opSymbols = newValue as? Array<String> {
                var newOpStack = [Op]()
                for opSymbol in opSymbols {
                    if let op = knownOps[opSymbol] {
                        newOpStack.append(op)
                    } else if let operand = NSNumberFormatter().numberFromString(opSymbol)?.doubleValue {
                        newOpStack.append(.Operand(operand))
                    }
                }
                opStack = newOpStack
            }
        }
    }
    
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func pushOperand(symbol: String) -> Double? {
        opStack.append(Op.Variable(symbol))
        return evaluate()
    }
    
    func pushConstant(symbol: String) -> Double? {
        opStack.append(Op.Constant(symbol))
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
    
    func clear() {
        opStack = [Op]()
    }
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        return result
    }

    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {

        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .Variable(let variable):
                return (variableValues[variable], remainingOps)
            case .Constant(let constant):
                return (constantValues[constant], remainingOps)
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps )
                }
            case .BinaryOperation(_, let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            }
        }
        return (nil, ops)
    }
    
    var description: String? {
        get{
            var (result, remainder) = description(opStack)

            while !remainder.isEmpty {
                let (desc, newRemainder) = description(remainder)
                result = "\(desc!), \(result!)"
                remainder = newRemainder
            }
            return result
        }
    }
    
    private func description(ops: [Op]) -> (result: String?, remainingOps: [Op]) {
        var remainingOps = ops

        if !ops.isEmpty {

            let op = remainingOps.removeLast()
            switch op {
            case .Constant(let constant):
                return (constant, remainingOps)
            case .Operand(let operand):
                return ("\(operand)", remainingOps)
            case .Variable(let variable):
                return (variable, remainingOps)
            case .UnaryOperation(let operation, _):
                let operandEvaluation = description(remainingOps)
                var operand = "?"
                if let result = operandEvaluation.result {
                    operand = result
                }
                return ("\(operation) ( \(operand) )", operandEvaluation.remainingOps )
            case .BinaryOperation(let operation, _):
                let op1Evaluation = description(remainingOps)

                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = description(op1Evaluation.remainingOps)

                    if let operand2 = op2Evaluation.result {
                        return ("(\(operand2) \(operation) \(operand1))", op2Evaluation.remainingOps)
                    } else {
                        return ("(? \(operation) \(operand1))", op2Evaluation.remainingOps)
                    }
                }
            }
        }
        return (nil, remainingOps)
    }
}