import Foundation
import Combine
import Charts
import Numerics

class CalculatorViewModel: ObservableObject {
    @Published var input: String = ""
    @Published var result: String = ""
    @Published var steps: [String] = []
    @Published var showSteps: Bool = false
    @Published var savedVariables: [String: Double] = [:]
    @Published var currentMode: CalculatorMode = .basic
    @Published var history: [HistoryEntry] = []
    @Published var graphData: [(x: Double, y: Double)] = []
    @Published var matrixA: [[Double]] = []
    @Published var matrixB: [[Double]] = []
    
    private let calculator = ExpressionCalculator()
    private let equationSolver = EquationSolver()
    private let unitConverter = UnitConverter()
    
    // Constants
    private let mathConstants = [
        "pi": Double.pi,
        "e": Double.e,
        "phi": 1.618033988749895, // Golden ratio
        "gamma": 0.577215664901532 // Euler-Mascheroni constant
    ]
    
    func calculate() {
        // Reset previous results
        steps = []
        
        // Replace mathematical constants
        let processedInput = replaceConstants(in: input)
        
        switch currentMode {
        case .basic, .scientific:
            calculateExpression(processedInput)
        case .converter:
            convertUnits()
        case .matrix:
            calculateMatrix()
        case .graph:
            generateGraphPoints()
        case .programmer:
            calculateProgrammer()
        case .statistics:
            calculateStatistics()
        }
        
        // Add to history if there's a result
        if !result.isEmpty && result.starts(with: "Error") == false {
            addToHistory()
        }
    }
    
    private func calculateExpression(_ expression: String) {
        // Check if it's an equation
        if expression.contains("=") {
            solveEquation()
            return
        }
        
        // Check for special formats like "20% of 50"
        if expression.lowercased().contains(" of ") && expression.contains("%") {
            calculatePercentageOf()
            return
        }
        
        // Check for variable assignment
        if let range = expression.range(of: #"^\s*([a-zA-Z][a-zA-Z0-9]*)\s*=\s*(.+)$"#, options: .regularExpression) {
            let matches = expression[range].split(separator: "=", maxSplits: 1)
            if matches.count == 2 {
                let varName = matches[0].trimmingCharacters(in: .whitespacesAndNewlines)
                let varExpression = String(matches[1])
                saveVariable(name: varName, expression: varExpression)
                return
            }
        }
        
        // Replace variables with their values
        let processedExpression = replaceVariables(in: expression)
        
        // Regular calculation
        do {
            let (value, calculationSteps) = try calculator.evaluate(expression: processedExpression)
            result = formatResult(value)
            steps = calculationSteps
        } catch {
            result = "Error: \(error.localizedDescription)"
        }
    }
    
    private func calculateMatrix() {
        do {
            let (value, matrixSteps) = try calculator.evaluateMatrix(matrixA: matrixA, matrixB: matrixB, operation: input)
            if let singleValue = value as? Double {
                result = formatResult(singleValue)
            } else if let matrix = value as? [[Double]] {
                result = formatMatrixResult(matrix)
            }
            steps = matrixSteps
        } catch {
            result = "Error: \(error.localizedDescription)"
        }
    }
    
    private func generateGraphPoints() {
        do {
            graphData = try calculator.generatePoints(for: input, range: -10...10, steps: 200)
            result = "Graph generated"
        } catch {
            result = "Error: \(error.localizedDescription)"
        }
    }
    
    private func calculateProgrammer() {
        do {
            let (value, programmerSteps) = try calculator.evaluateProgrammer(expression: input)
            result = formatProgrammerResult(value)
            steps = programmerSteps
        } catch {
            result = "Error: \(error.localizedDescription)"
        }
    }
    
    private func calculateStatistics() {
        do {
            let (value, statsSteps) = try calculator.evaluateStatistics(data: input)
            result = formatResult(value)
            steps = statsSteps
        } catch {
            result = "Error: \(error.localizedDescription)"
        }
    }
    
    private func solveEquation() {
        do {
            let (solution, solveSteps) = try equationSolver.solve(equation: input)
            result = solution
            steps = solveSteps
        } catch {
            result = "Error: \(error.localizedDescription)"
        }
    }
    
    private func convertUnits() {
        do {
            let (value, fromUnit, toUnit) = try unitConverter.parseConversionExpression(input)
            let (convertedValue, conversionSteps) = try unitConverter.convert(value, from: fromUnit, to: toUnit)
            result = "\(formatResult(convertedValue)) \(toUnit)"
            steps = conversionSteps
        } catch {
            result = "Error: \(error.localizedDescription)"
        }
    }
    
    private func calculatePercentageOf() {
        let components = input.lowercased().components(separatedBy: " of ")
        if components.count == 2 {
            let percentStr = components[0].replacingOccurrences(of: "%", with: "")
            if let percent = Double(percentStr), let total = Double(components[1]) {
                let value = (percent / 100.0) * total
                result = formatResult(value)
                steps = [
                    "Take \(percent)% of \(total)",
                    "\(percent) ÷ 100 = \(percent/100)",
                    "\(percent/100) × \(total) = \(value)"
                ]
            } else {
                result = "Error: Invalid percentage format"
            }
        }
    }
    
    private func saveVariable(name: String, expression: String) {
        let processedExpression = replaceConstants(in: expression)
        do {
            let (value, _) = try calculator.evaluate(expression: processedExpression)
            savedVariables[name] = value
            result = "\(name) = \(formatResult(value))"
        } catch {
            result = "Error: \(error.localizedDescription)"
        }
    }
    
    private func replaceVariables(in expression: String) -> String {
        var processedExpression = expression
        
        for (name, value) in savedVariables {
            let pattern = "\\b\(name)\\b"
            processedExpression = processedExpression.replacingOccurrences(
                of: pattern,
                with: String(value),
                options: .regularExpression
            )
        }
        
        return processedExpression
    }
    
    private func replaceConstants(in expression: String) -> String {
        var processedExpression = expression
        
        for (name, value) in mathConstants {
            let pattern = "\\b\(name)\\b"
            processedExpression = processedExpression.replacingOccurrences(
                of: pattern,
                with: String(value),
                options: [.regularExpression, .caseInsensitive]
            )
        }
        
        return processedExpression
    }
    
    private func formatResult(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", value)
        } else {
            return String(format: "%.6g", value)
        }
    }
    
    private func formatMatrixResult(_ matrix: [[Double]]) -> String {
        return matrix.map { row in
            "[\(row.map { formatResult($0) }.joined(separator: ", "))]"
        }.joined(separator: "\n")
    }
    
    private func formatProgrammerResult(_ value: Int) -> String {
        return """
        Decimal: \(value)
        Hex: \(String(value, radix: 16, uppercase: true))
        Binary: \(String(value, radix: 2))
        Octal: \(String(value, radix: 8))
        """
    }
    
    private func addToHistory() {
        let entry = HistoryEntry(
            id: UUID(),
            input: input,
            result: result,
            mode: currentMode,
            timestamp: Date()
        )
        history.insert(entry, at: 0)
        
        // Keep only last 100 entries
        if history.count > 100 {
            history.removeLast()
        }
    }
    
    func getStatisticalData() -> [Double] {
        // Parse input as comma-separated numbers
        return input.split(separator: ",")
            .compactMap { Double($0.trimmingCharacters(in: .whitespaces)) }
    }
    
    func clearInput() {
        input = ""
        result = ""
        steps = []
    }
    
    func clearAll() {
        clearInput()
        savedVariables = [:]
        graphData = []
        matrixA = []
        matrixB = []
    }
}

struct HistoryEntry: Identifiable {
    let id: UUID
    let input: String
    let result: String
    let mode: CalculatorMode
    let timestamp: Date
}
