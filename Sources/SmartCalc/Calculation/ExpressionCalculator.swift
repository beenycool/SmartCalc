import Foundation
import Numerics

class ExpressionCalculator {
    // Main evaluate function returns both result and steps
    func evaluate(expression: String) throws -> (Double, [String]) {
        var steps: [String] = []
        steps.append("Evaluating: \(expression)")
        
        // Check for matrix operations
        if expression.contains("[") && expression.contains("]") {
            return try evaluateMatrix(expression)
        }
        
        // Check for complex numbers
        if expression.contains("i") {
            return try evaluateComplex(expression)
        }
        
        // Tokenize the expression
        let tokens = tokenize(expression)
        
        // Convert infix to postfix (Shunting Yard algorithm)
        let postfix = try infixToPostfix(tokens)
        steps.append("Converted to postfix: \(postfix.map { $0.description }.joined(separator: " "))")
        
        // Evaluate postfix expression
        let (result, evalSteps) = try evaluatePostfix(postfix)
        steps.append(contentsOf: evalSteps)
        
        return (result, steps)
    }
    
    // MARK: - Token Types
    
    enum TokenType {
        case number(Double)
        case variable(String)
        case operation(String)
        case function(String)
        case leftParenthesis
        case rightParenthesis
        case matrix([[Double]])
        case complex(Complex<Double>)
        
        var description: String {
            switch self {
            case .number(let value):
                return "\(value)"
            case .variable(let name):
                return name
            case .operation(let op):
                return op
            case .function(let name):
                return name
            case .leftParenthesis:
                return "("
            case .rightParenthesis:
                return ")"
            case .matrix(let mat):
                return matrixToString(mat)
            case .complex(let z):
                return complexToString(z)
            }
        }
        
        var precedence: Int {
            switch self {
            case .operation(let op):
                switch op {
                case "+", "-": return 1
                case "*", "/": return 2
                case "^": return 3
                case "×": return 4  // Matrix multiplication
                default: return 0
                }
            default:
                return 0
            }
        }
    }
    
    // MARK: - Advanced Math Functions
    
    private let advancedFunctions: Set<String> = [
        // Trigonometric
        "sin", "cos", "tan", "asin", "acos", "atan",
        "sinh", "cosh", "tanh", "asinh", "acosh", "atanh",
        // Logarithmic
        "log", "ln", "log2", "log10",
        // Statistical
        "factorial", "permutation", "combination",
        // Special
        "gamma", "erf", "erfc", "beta",
        // Complex
        "real", "imag", "arg", "conj",
        // Matrix
        "det", "trace", "transpose", "inv"
    ]
    
    // MARK: - Matrix Operations
    
    private func evaluateMatrix(_ expression: String) throws -> (Double, [String]) {
        var steps: [String] = []
        
        // Parse matrices from string format
        let matrices = try parseMatrices(from: expression)
        
        // Identify operation
        let operation = try identifyMatrixOperation(expression)
        
        // Perform operation
        let result = try performMatrixOperation(matrices, operation)
        
        // Format steps
        steps.append("Matrix Operation: \(operation)")
        steps.append("Result: \(matrixToString(result))")
        
        // Return determinant for single matrix results
        if result.count == 1 && result[0].count == 1 {
            return (result[0][0], steps)
        }
        
        throw CalculationError.matrixResult(result)
    }
    
    // MARK: - Complex Number Operations
    
    private func evaluateComplex(_ expression: String) throws -> (Double, [String]) {
        var steps: [String] = []
        
        // Parse complex numbers from string
        let numbers = try parseComplexNumbers(from: expression)
        
        // Identify operation
        let operation = try identifyComplexOperation(expression)
        
        // Perform operation
        let result = try performComplexOperation(numbers, operation)
        
        // Format steps
        steps.append("Complex Operation: \(operation)")
        steps.append("Result: \(complexToString(result))")
        
        // Return magnitude for complex results
        return (result.magnitude, steps)
    }
    
    // MARK: - Helper Functions
    
    private func matrixToString(_ matrix: [[Double]]) -> String {
        return "[\(matrix.map { row in
            "[\(row.map { String(format: "%.2f", $0) }.joined(separator: ", "))]"
        }.joined(separator: ", "))]"
    }
    
    private func complexToString(_ z: Complex<Double>) -> String {
        let realPart = String(format: "%.2f", z.real)
        let imagPart = String(format: "%.2f", z.imaginary)
        return "\(realPart) + \(imagPart)i"
    }
    
    private func factorial(_ n: Int) -> Double {
        if n <= 1 { return 1 }
        return Double(n) * factorial(n - 1)
    }
    
    private func permutation(_ n: Int, _ r: Int) -> Double {
        return factorial(n) / factorial(n - r)
    }
    
    private func combination(_ n: Int, _ r: Int) -> Double {
        return factorial(n) / (factorial(r) * factorial(n - r))
    }
    
    // MARK: - Token Processing
    
    private func tokenize(_ expression: String) -> [TokenType] {
        var tokens = [TokenType]()
        let scanner = Scanner(string: expression)
        scanner.caseSensitive = false
        scanner.charactersToBeSkipped = CharacterSet.whitespaces
        
        while !scanner.isAtEnd {
            // Try to scan a number
            if let number = scanner.scanDouble() {
                tokens.append(.number(number))
                continue
            }
            
            // Try to scan an operation
            if let operation = scanner.scanCharacters(from: CharacterSet(charactersIn: "+-*/^×")) {
                tokens.append(.operation(operation))
                continue
            }
            
            // Scan parentheses
            if scanner.scanString("(") != nil {
                tokens.append(.leftParenthesis)
                continue
            }
            
            if scanner.scanString(")") != nil {
                tokens.append(.rightParenthesis)
                continue
            }
            
            // Try to scan a function or variable
            if let word = scanner.scanCharacters(from: .letters) {
                if advancedFunctions.contains(word.lowercased()) {
                    tokens.append(.function(word.lowercased()))
                } else {
                    tokens.append(.variable(word))
                }
                continue
            }
            
            // Skip unknown characters
            _ = scanner.scanCharacter()
        }
        
        return tokens
    }
    
    // MARK: - Error Handling
    
    enum CalculationError: Error, LocalizedError {
        case invalidExpression
        case unmatchedParentheses
        case divisionByZero
        case unsupportedOperation(String)
        case unsupportedFunction(String)
        case invalidArgument
        case matrixDimensionMismatch
        case singularMatrix
        case matrixResult([[Double]])
        case complexResult(Complex<Double>)
        
        var errorDescription: String? {
            switch self {
            case .invalidExpression:
                return "Invalid expression"
            case .unmatchedParentheses:
                return "Unmatched parentheses"
            case .divisionByZero:
                return "Division by zero"
            case .unsupportedOperation(let op):
                return "Unsupported operation: \(op)"
            case .unsupportedFunction(let func_):
                return "Unsupported function: \(func_)"
            case .invalidArgument:
                return "Invalid argument for function"
            case .matrixDimensionMismatch:
                return "Matrix dimensions do not match"
            case .singularMatrix:
                return "Matrix is singular (non-invertible)"
            case .matrixResult(let mat):
                return "Matrix result: \(mat)"
            case .complexResult(let z):
                return "Complex result: \(z)"
            }
        }
    }
    
    // Rest of the existing code remains the same...
}
