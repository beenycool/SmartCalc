import Foundation

class EquationSolver {
    private let calculator = ExpressionCalculator()
    
    /// Solves linear equations in the form ax + b = c
    func solve(equation: String) throws -> (String, [String]) {
        var steps: [String] = []
        steps.append("Original equation: \(equation)")
        
        // Split by equals sign
        let parts = equation.components(separatedBy: "=")
        guard parts.count == 2 else {
            throw EquationError.invalidEquation
        }
        
        let leftSide = parts[0].trimmingCharacters(in: .whitespacesAndNewlines)
        let rightSide = parts[1].trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Determine the variable to solve for
        guard let variable = findVariable(in: equation) else {
            throw EquationError.noVariableFound
        }
        steps.append("Solving for variable: \(variable)")
        
        // For simple linear equations
        if isSimpleLinearEquation(equation, variable: variable) {
            return try solveSimpleLinearEquation(leftSide: leftSide, rightSide: rightSide, variable: variable)
        }
        
        // For more complex equations, we'll use a symbolic approach
        return try solveSymbolically(leftSide: leftSide, rightSide: rightSide, variable: variable)
    }
    
    private func findVariable(in equation: String) -> String? {
        // Simple implementation: find the first alphabetic character that's not a function name
        // This could be enhanced with better parsing
        let knownFunctions = ["sin", "cos", "tan", "log", "ln", "sqrt"]
        
        for char in equation where char.isLetter {
            let varName = String(char)
            if !knownFunctions.contains(varName) {
                return varName
            }
        }
        
        return nil
    }
    
    private func isSimpleLinearEquation(_ equation: String, variable: String) -> Bool {
        // Check if equation is of form ax + b = c
        // This is a simple check that could be enhanced
        let pattern = "^[\\d\\s\\+\\-\\*\\/]*\(variable)[\\d\\s\\+\\-\\*\\/]*=\\s*[\\d\\.\\s\\+\\-\\*\\/]*$"
        return equation.range(of: pattern, options: .regularExpression) != nil
    }
    
    private func solveSimpleLinearEquation(leftSide: String, rightSide: String, variable: String) throws -> (String, [String]) {
        var steps: [String] = []
        
        // Rearrange to standard form: ax + b = c
        steps.append("Moving all terms with \(variable) to the left side, and all other terms to the right side")
        
        // Isolate variable terms and constants
        var coefficientOfVariable = 1.0
        var constantTerm = 0.0
        
        // Parse the equation - this is a simplified approach
        let modifiedEquation = "\(leftSide) - (\(rightSide))"
        steps.append("Rearranging to: \(modifiedEquation) = 0")
        
        // For a simple case where we have "2x + 3 = 7"
        // We would extract coefficient 2 and constant -4 (3-7)
        
        // In a real implementation, we'd parse the equation more thoroughly
        // Here's a very simplified example for "ax + b = c" form:
        if let aStr = extractCoefficient(from: leftSide, for: variable),
           let a = Double(aStr),
           let b = extractConstant(from: leftSide),
           let c = Double(rightSide) {
            
            coefficientOfVariable = a
            constantTerm = c - b
            
            steps.append("Coefficient of \(variable): \(a)")
            steps.append("Constant term on left: \(b)")
            steps.append("Constant term on right: \(c)")
            steps.append("Rearranged equation: \(a)\(variable) = \(c) - \(b)")
            steps.append("\(a)\(variable) = \(constantTerm)")
            
            // Solve for variable
            if coefficientOfVariable == 0 {
                if constantTerm == 0 {
                    return ("Infinite solutions", steps)
                } else {
                    return ("No solution", steps)
                }
            }
            
            let solution = constantTerm / coefficientOfVariable
            steps.append("\(variable) = \(constantTerm) / \(coefficientOfVariable)")
            steps.append("\(variable) = \(solution)")
            
            return ("\(variable) = \(formatResult(solution))", steps)
        }
        
        // If the simple extraction failed, we need a more comprehensive equation parser
        throw EquationError.parsingError
    }
    
    private func extractCoefficient(from expression: String, for variable: String) -> String? {
        // Very simplified - would need proper parsing in a real implementation
        // Looks for patterns like "2x" or "x"
        let pattern = "([\\+\\-]?\\s*\\d*\\s*)\(variable)"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        
        let range = NSRange(expression.startIndex..., in: expression)
        if let match = regex.firstMatch(in: expression, range: range) {
            let coeffRange = match.range(at: 1)
            if let swiftRange = Range(coeffRange, in: expression) {
                let coeff = expression[swiftRange].trimmingCharacters(in: .whitespaces)
                if coeff.isEmpty || coeff == "+" {
                    return "1"
                } else if coeff == "-" {
                    return "-1"
                }
                return coeff
            }
        }
        return nil
    }
    
    private func extractConstant(from expression: String) -> Double? {
        // Very simplified - would need proper parsing in a real implementation
        // Assumes any number not attached to a variable is a constant
        for component in expression.components(separatedBy: CharacterSet(charactersIn: "+-")) {
            let trimmed = component.trimmingCharacters(in: .whitespaces)
            if !trimmed.isEmpty && !trimmed.contains(where: { $0.isLetter }), let value = Double(trimmed) {
                return value
            }
        }
        return 0
    }
    
    private func solveSymbolically(leftSide: String, rightSide: String, variable: String) throws -> (String, [String]) {
        // This would be a more complex symbolic manipulation implementation
        // For now, we'll throw an error since this is beyond our scope
        throw EquationError.equationTooComplex
    }
    
    private func formatResult(_ value: Double) -> String {
        // Format the result to avoid showing .0 for integer results
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", value)
        } else {
            return String(format: "%.6g", value)
        }
    }
}

enum EquationError: Error, LocalizedError {
    case invalidEquation
    case noVariableFound
    case parsingError
    case equationTooComplex
    
    var errorDescription: String? {
        switch self {
        case .invalidEquation:
            return "Invalid equation format"
        case .noVariableFound:
            return "No variable found to solve for"
        case .parsingError:
            return "Unable to parse equation terms"
        case .equationTooComplex:
            return "Equation too complex for this solver"
        }
    }
}
