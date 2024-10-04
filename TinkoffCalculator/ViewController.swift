//
//  ViewController.swift
//  TinkoffCalculator
//
//  Created by Hakob Ghlijyan on 01.10.2024.
//

import UIKit

enum CalculationError: Error {
    case dividedByZero
}

enum Operation: String {
    case add = "+"
    case substruct = "-"
    case multiply = "x"
    case divide = "/"
    
    func calculate(_ num1: Double, _ num2: Double) throws  -> Double {
        switch self {
        case .add:
            return num1 + num2
        case .substruct:
            return num1 - num2
        case .multiply:
            return num1 * num2
        case .divide:
            if num2 == 0 {
                throw CalculationError.dividedByZero
            }
            return num1 / num2
        }
    }
}

enum ClaculationHistoryItem {
    case number(Double)
    case operation(Operation)
}

class ViewController: UIViewController {
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        guard let buttonText = sender.titleLabel?.text else {
            return print("Non Title")
        }
        if buttonText == "," && label.text?.contains(",") == true { return }
        
        if label.text == "0" {
            label.text = buttonText
        } else {
            label.text?.append(buttonText)
        }
        
    }
    
    @IBAction func operationButtonPressed(_ sender: UIButton) {
        guard
            let buttonText = sender.titleLabel?.text,
            let buttonOperation = Operation(rawValue: buttonText)
            else { return }
         
        guard
            let labelText = label.text,
            let labelNumber = numberFormater.number(from: labelText)?.doubleValue
            else { return }
        
        calculationHistory.append(.number(labelNumber))
        calculationHistory.append(.operation(buttonOperation))
        
        resetLabelText()
                
    }
    
    @IBAction func clearButtonPressed() {
        calculationHistory.removeAll()
        resetLabelText()
    }
    
    @IBAction func calculateButtonPressed() {
        guard
            let labelText = label.text,
            let labelNumber = numberFormater.number(from: labelText)?.doubleValue
            else { return }
        
        calculationHistory.append(.number(labelNumber))
        
        do {
            let result = try calculate()
            
            label.text = numberFormater.string(from: NSNumber(value: result))
        } catch {
            label.text = "Error"
        }
                
        calculationHistory.removeAll()
    }
    
    var calculationHistory: [ClaculationHistoryItem] = []
    
    @IBOutlet weak var label: UILabel!
    
    lazy var numberFormater: NumberFormatter = {
        let numberFormater = NumberFormatter()
        
        numberFormater.usesGroupingSeparator = false
        numberFormater.locale = Locale(identifier: "ru_RU")
        numberFormater.numberStyle = .decimal
        
        return numberFormater
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resetLabelText()
    }
    
    func resetLabelText() {
        label.text = "0"
    }
    
    func calculate() throws -> Double {
        guard case .number(let firstNumber) = calculationHistory[0] else { return 0 }
        var currentResult = firstNumber
        
        for index in stride(from: 1, to: calculationHistory.count - 1, by: 2) {
            guard
                case .operation(let operation) = calculationHistory[index],
                case .number(let number) = calculationHistory[index + 1]
            else { break }
            
            currentResult =  try operation.calculate(currentResult, number)
        }
        
        return currentResult
    }
    
    
}

