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
    
    // MARK: - Infix to Postfix Conversion
    
    private func infixToPostfix(_ tokens: [TokenType]) throws -> [TokenType] {
        var output = [TokenType]()
        var operatorStack = [TokenType]()
        
        for token in tokens {
            switch token {
            case .number, .variable:
                output.append(token)
                
            case .function:
                operatorStack.append(token)
                
            case .leftParenthesis:
                operatorStack.append(token)
                
            case .rightParenthesis:
                while let top = operatorStack.last, case .operation = top {
                    output.append(operatorStack.removeLast())
                }
                
                if case .function = operatorStack.last {
                    output.append(operatorStack.removeLast())
                }
                
                if operatorStack.isEmpty || operatorStack.last != .leftParenthesis {
                    throw CalculationError.unmatchedParentheses
                }
                
                operatorStack.removeLast()
                
            case .operation:
                while let top = operatorStack.last {
                    if case .operation = top, top.precedence >= token.precedence {
                        output.append(operatorStack.removeLast())
                    } else {
                        break
                    }
                }
                operatorStack.append(token)
                
            default:
                break
            }
        }
        
        while let op = operatorStack.last {
            if op == .leftParenthesis {
                throw CalculationError.unmatchedParentheses
            }
            output.append(operatorStack.removeLast())
        }
        
        return output
    }
    
    // MARK: - Postfix Evaluation
    
    private func evaluatePostfix(_ tokens: [TokenType]) throws -> (Double, [String]) {
        var stack = [Double]()
        var steps = [String]()
        
        for token in tokens {
            switch token {
            case .number(let value):
                stack.append(value)
                
            case .operation(let op):
                guard stack.count >= 2 else { throw CalculationError.invalidExpression }
                let b = stack.removeLast()
                let a = stack.removeLast()
                
                let result: Double
                switch op {
                case "+":
                    result = a + b
                case "-":
                    result = a - b
                case "*":
                    result = a * b
                case "/":
                    guard b != 0 else { throw CalculationError.divisionByZero }
                    result = a / b
                case "^":
                    result = pow(a, b)
                default:
                    throw CalculationError.unsupportedOperation(op)
                }
                
                stack.append(result)
                steps.append("\(a) \(op) \(b) = \(result)")
                
            case .function(let name):
                guard let value = stack.last else { throw CalculationError.invalidExpression }
                
                let result: Double
                switch name {
                case "sin": result = sin(value)
                case "cos": result = cos(value)
                case "tan": result = tan(value)
                case "asin": result = asin(value)
                case "acos": result = acos(value)
                case "atan": result = atan(value)
                case "sinh": result = sinh(value)
                case "cosh": result = cosh(value)
                case "tanh": result = tanh(value)
                case "log": result = log10(value)
                case "ln": result = log(value)
                case "sqrt": result = sqrt(value)
                default:
                    throw CalculationError.unsupportedFunction(name)
                }
                
                _ = stack.removeLast()
                stack.append(result)
                steps.append("\(name)(\(value)) = \(result)")
                
            default:
                throw CalculationError.invalidExpression
            }
        }
        
        guard stack.count == 1 else { throw CalculationError.invalidExpression }
        return (stack[0], steps)
    }
    
    // MARK: - Matrix Operations
    
    private func parseMatrices(from expression: String) throws -> [[[Double]]] {
        let pattern = "\\[(\\d+(?:,\\d+)*(?:;\\d+(?:,\\d+)*)*)]"
        let regex = try NSRegularExpression(pattern: pattern)
        let range = NSRange(expression.startIndex..<expression.endIndex, in: expression)
        let matches = regex.matches(in: expression, range: range)
        
        return try matches.map { match in
            guard let matchRange = Range(match.range, in: expression) else {
                throw CalculationError.invalidExpression
            }
            
            let matrixStr = String(expression[matchRange])
            let content = matrixStr.dropFirst().dropLast()
            let rows = content.split(separator: ";")
            
            return try rows.map { row in
                try row.split(separator: ",").map {
                    guard let num = Double(String($0).trimmingCharacters(in: .whitespaces)) else {
                        throw CalculationError.invalidExpression
                    }
                    return num
                }
            }
        }
    }
    
    private func identifyMatrixOperation(_ expression: String) throws -> String {
        let operators = ["×", "+", "-"]
        return operators.first { expression.contains($0) } ?? "det"
    }
    
    private func performMatrixOperation(_ matrices: [[[Double]]], _ operation: String) throws -> [[Double]] {
        guard !matrices.isEmpty else { throw CalculationError.invalidExpression }
        
        switch operation {
        case "×":
            guard matrices.count == 2 else { throw CalculationError.invalidExpression }
            return try multiplyMatrices(matrices[0], matrices[1])
            
        case "+":
            guard matrices.count == 2 else { throw CalculationError.invalidExpression }
            return try addMatrices(matrices[0], matrices[1])
            
        case "-":
            guard matrices.count == 2 else { throw CalculationError.invalidExpression }
            return try subtractMatrices(matrices[0], matrices[1])
            
        case "det":
            guard matrices.count == 1 else { throw CalculationError.invalidExpression }
            return [[try determinant(matrices[0])]]
            
        default:
            throw CalculationError.unsupportedOperation(operation)
        }
    }
    
    private func multiplyMatrices(_ a: [[Double]], _ b: [[Double]]) throws -> [[Double]] {
        guard !a.isEmpty && !b.isEmpty && !a[0].isEmpty && !b[0].isEmpty else {
            throw CalculationError.invalidExpression
        }
        
        let m = a.count
        let n = a[0].count
        let p = b[0].count
        
        guard b.count == n else { throw CalculationError.matrixDimensionMismatch }
        
        var result = Array(repeating: Array(repeating: 0.0, count: p), count: m)
        
        for i in 0..<m {
            for j in 0..<p {
                for k in 0..<n {
                    result[i][j] += a[i][k] * b[k][j]
                }
            }
        }
        
        return result
    }
    
    private func addMatrices(_ a: [[Double]], _ b: [[Double]]) throws -> [[Double]] {
        guard a.count == b.count && a[0].count == b[0].count else {
            throw CalculationError.matrixDimensionMismatch
        }
        
        return zip(a, b).map { row1, row2 in
            zip(row1, row2).map(+)
        }
    }
    
    private func subtractMatrices(_ a: [[Double]], _ b: [[Double]]) throws -> [[Double]] {
        guard a.count == b.count && a[0].count == b[0].count else {
            throw CalculationError.matrixDimensionMismatch
        }
        
        return zip(a, b).map { row1, row2 in
            zip(row1, row2).map(-)
        }
    }
    
    private func determinant(_ matrix: [[Double]]) throws -> Double {
        let n = matrix.count
        guard n == matrix[0].count else { throw CalculationError.matrixDimensionMismatch }
        
        if n == 1 {
            return matrix[0][0]
        }
        
        if n == 2 {
            return matrix[0][0] * matrix[1][1] - matrix[0][1] * matrix[1][0]
        }
        
        var det = 0.0
        for j in 0..<n {
            var submatrix = [[Double]]()
            for i in 1..<n {
                var row = [Double]()
                for k in 0..<n where k != j {
                    row.append(matrix[i][k])
                }
                submatrix.append(row)
            }
            let sign = (j % 2 == 0) ? 1.0 : -1.0
            det += sign * matrix[0][j] * (try determinant(submatrix))
        }
        return det
    }
    
    // MARK: - Complex Number Operations
    
    private func parseComplexNumbers(from expression: String) throws -> [Complex<Double>] {
        let pattern = "(-?\\d+(?:\\.\\d+)?)([-+])(-?\\d+(?:\\.\\d+)?)i"
        let regex = try NSRegularExpression(pattern: pattern)
        let range = NSRange(expression.startIndex..<expression.endIndex, in: expression)
        let matches = regex.matches(in: expression, range: range)
        
        return try matches.map { match -> Complex<Double> in
            guard let matchRange = Range(match.range, in: expression),
                  match.numberOfRanges == 4,
                  let realRange = Range(match.range(at: 1), in: expression),
                  let opRange = Range(match.range(at: 2), in: expression),
                  let imagRange = Range(match.range(at: 3), in: expression),
                  let real = Double(String(expression[realRange])),
                  let imag = Double(String(expression[imagRange])) else {
                throw CalculationError.invalidExpression
            }
            
            let sign = expression[opRange] == "+" ? 1.0 : -1.0
            return Complex(real, sign * imag)
        }
    }
    
    private func identifyComplexOperation(_ expression: String) throws -> String {
        let operators = ["+", "-", "*", "/", "conj"]
        return operators.first { expression.contains($0) } ?? "abs"
    }
    
    private func performComplexOperation(_ numbers: [Complex<Double>], _ operation: String) throws -> Complex<Double> {
        guard !numbers.isEmpty else { throw CalculationError.invalidExpression }
        
        switch operation {
        case "+":
            guard numbers.count == 2 else { throw CalculationError.invalidExpression }
            return numbers[0] + numbers[1]
            
        case "-":
            guard numbers.count == 2 else { throw CalculationError.invalidExpression }
            return numbers[0] - numbers[1]
            
        case "*":
            guard numbers.count == 2 else { throw CalculationError.invalidExpression }
            return numbers[0] * numbers[1]
            
        case "/":
            guard numbers.count == 2 else { throw CalculationError.invalidExpression }
            guard numbers[1] != Complex(0, 0) else { throw CalculationError.divisionByZero }
            return numbers[0] / numbers[1]
            
        case "conj":
            guard numbers.count == 1 else { throw CalculationError.invalidExpression }
            return numbers[0].conjugate
            
        case "abs":
            guard numbers.count == 1 else { throw CalculationError.invalidExpression }
            return Complex(numbers[0].magnitude, 0)
            
        default:
            throw CalculationError.unsupportedOperation(operation)
        }
    }
    
    // MARK: - Graphing Functions
    
    func generatePoints(for function: String, in range: ClosedRange<Double> = -10...10, steps: Int = 200) throws -> [(Double, Double)] {
        let dx = (range.upperBound - range.lowerBound) / Double(steps)
        var points = [(Double, Double)]()
        
        for i in 0...steps {
            let x = range.lowerBound + Double(i) * dx
            let expression = function.replacingOccurrences(of: "x", with: "\(x)")
            
            do {
                let (y, _) = try evaluate(expression)
                if y.isFinite {
                    points.append((x, y))
                }
            } catch {
                continue
            }
        }
        
        return points
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
