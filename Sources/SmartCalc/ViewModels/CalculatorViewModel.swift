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
    
    // AI settings
    @Published var aiSettings = AISettings()
    @Published var isProcessingAIRequest: Bool = false
    
    // Finance calculators
    @Published var selectedFinanceCalculator: FinanceCalculatorType = .mortgage
    @Published var mortgageCalculator = MortgageCalculator()
    @Published var compoundInterestCalculator = CompoundInterestCalculator()
    @Published var tipCalculator = TipCalculator()
    @Published var discountCalculator = DiscountCalculator()
    @Published var currencyExchange = CurrencyExchange()
    @Published var dateCalculator = DateCalculator()
    
    // Finance calculator inputs
    @Published var loanAmount: Double = 300000
    @Published var interestRate: Double = 4.5
    @Published var loanTermYears: Int = 30
    @Published var amortizationSchedule: [AmortizationEntry] = []
    
    // Compound interest inputs
    @Published var principal: Double = 10000
    @Published var annualReturnRate: Double = 7.0
    @Published var investmentYears: Int = 20
    @Published var compoundingFrequency: Int = 12
    @Published var monthlyContribution: Double = 500
    
    // Tip calculator inputs
    @Published var billAmount: Double = 100
    @Published var tipPercentage: Double = 15
    @Published var numberOfPeople: Int = 2
    
    // Discount calculator inputs
    @Published var originalPrice: Double = 100
    @Published var discountPercentage: Double = 20
    @Published var taxRate: Double = 7.5
    
    // Currency exchange inputs
    @Published var exchangeAmount: Double = 100
    @Published var fromCurrency: String = "USD"
    @Published var toCurrency: String = "EUR"
    @Published var exchangeRate: Double = 0.92
    
    // Date calculator inputs
    @Published var startDate: Date = Date()
    @Published var endDate: Date = Date().addingTimeInterval(86400 * 30) // 30 days
    @Published var countWeekdaysOnly: Bool = false
    
    private let calculator = ExpressionCalculator()
    private let equationSolver = EquationSolver()
    private let unitConverter = UnitConverter()
    private var aiProvider: AIProvider?
    
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
        case .ai:
            processAIRequest()
        case .finance:
            calculateFinance()
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
            // Parse matrices from input string
            let matrixExpression = input.trimmingCharacters(in: .whitespaces)
            let (value, matrixSteps) = try calculator.evaluate(expression: matrixExpression)
            
            // Handle different return types
            if let mat = value as? [[Double]] {
                result = formatMatrixResult(mat)
            } else {
                result = formatResult(value)
            }
            
            // Update matrix visualization
            if let matches = try? parseMatrixInput(matrixExpression) {
                if matches.count > 0 { matrixA = matches[0] }
                if matches.count > 1 { matrixB = matches[1] }
            }
            
            steps = matrixSteps
        } catch {
            result = "Error: \(error.localizedDescription)"
        }
    }
    
    private func parseMatrixInput(_ input: String) throws -> [[[Double]]] {
        let pattern = "\\[(\\d+(?:,\\d+)*(?:;\\d+(?:,\\d+)*)*)]"
        let regex = try NSRegularExpression(pattern: pattern)
        let range = NSRange(input.startIndex..<input.endIndex, in: input)
        let matches = regex.matches(in: input, range: range)
        
        return try matches.map { match in
            guard let matchRange = Range(match.range, in: input) else {
                throw CalculationError.invalidExpression
            }
            
            let matrixStr = String(input[matchRange])
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
    
    private func generateGraphPoints() {
        do {
            // Check if input is in correct format (y = f(x))
            let expression = input.trimmingCharacters(in: .whitespaces)
            guard expression.lowercased().hasPrefix("y = ") || expression.lowercased().hasPrefix("y=") else {
                throw CalculationError.invalidExpression
            }
            
            // Extract the function part after "y ="
            let functionPart = expression.dropFirst(expression.contains(" = ") ? 4 : 2).trimmingCharacters(in: .whitespaces)
            
            // Generate points
            graphData = try calculator.generatePoints(for: functionPart)
            
            // Calculate some key points for display
            let keyPoints = try findKeyPoints(functionPart)
            
            result = "Graph generated successfully"
            steps = [
                "Function: y = \(functionPart)",
                "Domain: [-10, 10]",
                "Points generated: \(graphData.count)",
                "Key points: \(keyPoints)"
            ]
        } catch {
            result = "Error: \(error.localizedDescription)"
            graphData = []
        }
    }
    
    private func findKeyPoints(_ function: String) throws -> String {
        var keyPoints = [(x: Double, y: Double)]()
        
        // Check y value at x = 0 (y-intercept)
        if let (y, _) = try? calculator.evaluate(expression: function.replacingOccurrences(of: "x", with: "0")) {
            keyPoints.append((x: 0, y: y))
        }
        
        // Check x value at y = 0 (x-intercept) by trying a few points
        for x in [-10, -5, 0, 5, 10] {
            let (y, _) = try calculator.evaluate(expression: function.replacingOccurrences(of: "x", with: "\(x)"))
            if abs(y) < 0.0001 { // Close enough to zero
                keyPoints.append((x: Double(x), y: 0))
            }
        }
        
        return keyPoints.map { "(\(formatResult($0.x)), \(formatResult($0.y)))" }.joined(separator: ", ")
    }
    
    private func calculateProgrammer() {
        do {
            // Parse the input to identify base and operation
            let components = input.lowercased().split(separator: " ")
            guard components.count >= 1 else {
                throw CalculationError.invalidExpression
            }
            
            var programmerSteps = [String]()
            var finalValue: Int = 0
            
            if components.count == 1 {
                // Single number conversion
                finalValue = try parseNumber(String(components[0]))
                programmerSteps.append("Converting \(components[0])")
            } else if components.count == 3 {
                // Binary operation (e.g. "FF AND 0F")
                let a = try parseNumber(String(components[0]))
                let op = String(components[1])
                let b = try parseNumber(String(components[2]))
                
                finalValue = try performBitwiseOperation(a, op, b)
                programmerSteps.append("Performing \(a) \(op) \(b)")
            } else {
                throw CalculationError.invalidExpression
            }
            
            result = formatProgrammerResult(finalValue)
            programmerSteps.append(result)
            steps = programmerSteps
            
        } catch {
            result = "Error: \(error.localizedDescription)"
        }
    }
    
    private func parseNumber(_ str: String) throws -> Int {
        if str.hasPrefix("0x") {
            return try Int(str.dropFirst(2), radix: 16) ?? 0
        } else if str.hasPrefix("0b") {
            return try Int(str.dropFirst(2), radix: 2) ?? 0
        } else if str.hasPrefix("0o") {
            return try Int(str.dropFirst(2), radix: 8) ?? 0
        } else if let decimal = Int(str) {
            return decimal
        }
        throw CalculationError.invalidExpression
    }
    
    private func performBitwiseOperation(_ a: Int, _ op: String, _ b: Int) throws -> Int {
        switch op.uppercased() {
        case "AND": return a & b
        case "OR": return a | b
        case "XOR": return a ^ b
        case "<<": return a << b
        case ">>": return a >> b
        default: throw CalculationError.unsupportedOperation(op)
        }
    }
    
    private func calculateStatistics() {
        do {
            // Parse input string to array of numbers
            let numbers = input.split(separator: ",").compactMap { Double($0.trimmingCharacters(in: .whitespaces)) }
            guard !numbers.isEmpty else { throw CalculationError.invalidExpression }
            
            // Calculate statistics
            let n = Double(numbers.count)
            let sum = numbers.reduce(0, +)
            let mean = sum / n
            
            // Calculate variance and standard deviation
            let sumSquaredDiff = numbers.reduce(0) { $0 + pow($1 - mean, 2) }
            let variance = sumSquaredDiff / n
            let stdDev = sqrt(variance)
            
            // Calculate median
            let sorted = numbers.sorted()
            let median = n.truncatingRemainder(dividingBy: 2) == 0 
                ? (sorted[Int(n/2) - 1] + sorted[Int(n/2)]) / 2 
                : sorted[Int(n/2)]
            
            // Calculate mode
            let frequencies = Dictionary(grouping: numbers, by: { $0 }).mapValues { $0.count }
            let maxFrequency = frequencies.values.max() ?? 0
            let modes = frequencies.filter { $0.value == maxFrequency }.keys.sorted()
            
            result = """
            Mean: \(formatResult(mean))
            Median: \(formatResult(median))
            Mode: \(modes.map { formatResult($0) }.joined(separator: ", "))
            Standard Deviation: \(formatResult(stdDev))
            """
            
            steps = [
                "Count: \(Int(n))",
                "Sum: \(formatResult(sum))",
                "Mean: \(formatResult(mean))",
                "Median: \(formatResult(median))",
                "Mode: \(modes.map { formatResult($0) }.joined(separator: ", "))",
                "Variance: \(formatResult(variance))",
                "Standard Deviation: \(formatResult(stdDev))"
            ]
        } catch {
            result = "Error: \(error.localizedDescription)"
        }
    }
    
    private func processAIRequest() {
        // Set up AI processing state
        isProcessingAIRequest = true
        result = "Processing request..."
        
        // Use selected AI provider to process request
        submitAIQuery(input) { response, error in
            DispatchQueue.main.async {
                self.isProcessingAIRequest = false
                
                if let error = error {
                    self.result = "Error: \(error.localizedDescription)"
                    return
                }
                
                guard let response = response else {
                    self.result = "Error: No response received"
                    return
                }
                
                self.result = response.result
                if self.aiSettings.showStepByStep {
                    self.steps = response.steps
                }
            }
        }
    }
    
    private func calculateFinance() {
        switch selectedFinanceCalculator {
        case .mortgage, .loanPayment:
            calculateMortgage()
        case .investment, .compoundInterest:
            calculateInvestment()
        case .tipCalculator:
            calculateTip()
        case .discount:
            calculateDiscount()
        case .currencyExchange:
            calculateCurrencyExchange()
        case .dateCalculator:
            calculateDateDifference()
        case .retirement:
            calculateRetirement()
        case .fuelEfficiency:
            calculateFuelEfficiency()
        }
    }
    
    private func calculateMortgage() {
        let monthlyPayment = mortgageCalculator.calculateMonthlyPayment(
            loanAmount: loanAmount,
            interestRate: interestRate,
            loanTermYears: loanTermYears
        )
        
        // Generate amortization schedule
        amortizationSchedule = mortgageCalculator.generateAmortizationSchedule(
            loanAmount: loanAmount,
            interestRate: interestRate,
            loanTermYears: loanTermYears
        )
        
        // Calculate total payments and interest
        let totalPayments = monthlyPayment * Double(loanTermYears * 12)
        let totalInterest = totalPayments - loanAmount
        
        result = """
        Monthly Payment: \(formatCurrency(monthlyPayment))
        Total Payments: \(formatCurrency(totalPayments))
        Total Interest: \(formatCurrency(totalInterest))
        """
        
        steps = [
            "Loan Amount: \(formatCurrency(loanAmount))",
            "Interest Rate: \(String(format: "%.2f", interestRate))%",
            "Loan Term: \(loanTermYears) years",
            "Monthly Payment: \(formatCurrency(monthlyPayment))",
            "Total of \(loanTermYears * 12) Payments: \(formatCurrency(totalPayments))",
            "Total Interest: \(formatCurrency(totalInterest))"
        ]
    }
    
    private func calculateInvestment() {
        let futureValue = compoundInterestCalculator.calculateFutureValue(
            principal: principal,
            annualRate: annualReturnRate,
            years: investmentYears,
            compoundingFrequency: compoundingFrequency,
            monthlyContribution: monthlyContribution
        )
        
        let totalContributions = principal + (monthlyContribution * Double(12 * investmentYears))
        let totalInterest = futureValue - totalContributions
        
        result = """
        Future Value: \(formatCurrency(futureValue))
        Total Interest Earned: \(formatCurrency(totalInterest))
        """
        
        steps = [
            "Initial Principal: \(formatCurrency(principal))",
            "Annual Return Rate: \(String(format: "%.2f", annualReturnRate))%",
            "Monthly Contribution: \(formatCurrency(monthlyContribution))",
            "Investment Period: \(investmentYears) years",
            "Compounding Frequency: \(compoundingFrequencyName(compoundingFrequency))",
            "Total Contributions: \(formatCurrency(totalContributions))",
            "Interest Earned: \(formatCurrency(totalInterest))",
            "Final Value: \(formatCurrency(futureValue))"
        ]
    }
    
    private func calculateTip() {
        let (tipAmount, totalAmount, perPersonAmount) = tipCalculator.calculateTip(
            billAmount: billAmount,
            tipPercentage: tipPercentage,
            numberOfPeople: numberOfPeople
        )
        
        result = """
        Tip Amount: \(formatCurrency(tipAmount))
        Total Bill: \(formatCurrency(totalAmount))
        Amount Per Person: \(formatCurrency(perPersonAmount))
        """
        
        steps = [
            "Bill Amount: \(formatCurrency(billAmount))",
            "Tip Percentage: \(String(format: "%.1f", tipPercentage))%",
            "Number of People: \(numberOfPeople)",
            "Tip Amount: \(formatCurrency(tipAmount))",
            "Total Bill with Tip: \(formatCurrency(totalAmount))",
            "Amount Per Person: \(formatCurrency(perPersonAmount))"
        ]
    }
    
    private func calculateDiscount() {
        let (discountAmount, savedAmount, finalPrice, taxAmount) = discountCalculator.calculateDiscountedPrice(
            originalPrice: originalPrice,
            discountPercentage: discountPercentage,
            taxRate: taxRate
        )
        
        result = """
        Discounted Price: \(formatCurrency(finalPrice - taxAmount))
        Final Price (with tax): \(formatCurrency(finalPrice))
        You Save: \(formatCurrency(savedAmount))
        """
        
        steps = [
            "Original Price: \(formatCurrency(originalPrice))",
            "Discount: \(String(format: "%.1f", discountPercentage))%",
            "Discount Amount: \(formatCurrency(discountAmount))",
            "Price After Discount: \(formatCurrency(originalPrice - discountAmount))",
            "Tax Rate: \(String(format: "%.2f", taxRate))%",
            "Tax Amount: \(formatCurrency(taxAmount))",
            "Final Price: \(formatCurrency(finalPrice))"
        ]
    }
    
    private func calculateCurrencyExchange() {
        let convertedAmount = currencyExchange.convert(
            amount: exchangeAmount,
            fromCurrency: fromCurrency,
            toCurrency: toCurrency,
            exchangeRate: exchangeRate
        )
        
        result = "\(formatCurrency(exchangeAmount)) \(fromCurrency) = \(formatCurrency(convertedAmount)) \(toCurrency)"
        
        steps = [
            "Converting from \(fromCurrency) to \(toCurrency)",
            "Amount: \(formatCurrency(exchangeAmount)) \(fromCurrency)",
            "Exchange Rate: 1 \(fromCurrency) = \(exchangeRate) \(toCurrency)",
            "Calculation: \(formatCurrency(exchangeAmount)) × \(exchangeRate)",
            "Result: \(formatCurrency(convertedAmount)) \(toCurrency)"
        ]
    }
    
    private func calculateDateDifference() {
        let daysBetween = dateCalculator.daysBetween(
            startDate: startDate,
            endDate: endDate,
            countWeekdaysOnly: countWeekdaysOnly
        )
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        let startDateString = dateFormatter.string(from: startDate)
        let endDateString = dateFormatter.string(from: endDate)
        
        if countWeekdaysOnly {
            result = "\(daysBetween) business days between dates"
        } else {
            result = "\(daysBetween) days between dates"
        }
        
        steps = [
            "Start Date: \(startDateString)",
            "End Date: \(endDateString)",
            countWeekdaysOnly ? "Counting business days only" : "Counting all days",
            "Total: \(daysBetween) days"
        ]
    }
    
    private func calculateRetirement() {
        // Simplified retirement calculation
        let futureValue = compoundInterestCalculator.calculateFutureValue(
            principal: principal,
            annualRate: annualReturnRate,
            years: investmentYears,
            compoundingFrequency: 12,
            monthlyContribution: monthlyContribution
        )
        
        // Estimated monthly income during retirement (4% withdrawal rule)
        let monthlyIncome = (futureValue * 0.04) / 12
        
        result = """
        Retirement Savings: \(formatCurrency(futureValue))
        Monthly Income: \(formatCurrency(monthlyIncome))
        """
        
        steps = [
            "Initial Savings: \(formatCurrency(principal))",
            "Monthly Contribution: \(formatCurrency(monthlyContribution))",
            "Years Until Retirement: \(investmentYears)",
            "Expected Annual Return: \(String(format: "%.2f", annualReturnRate))%",
            "Estimated Retirement Savings: \(formatCurrency(futureValue))",
            "Estimated Monthly Income (4% Rule): \(formatCurrency(monthlyIncome))"
        ]
    }
    
    private func calculateFuelEfficiency() {
        // Simple fuel efficiency calculator
        // Assuming input format: "distance,fuel,unit"
        // Example: "100,5,mpg" or "100,5,l/100km"
        
        let components = input.components(separatedBy: ",")
        guard components.count >= 2 else {
            result = "Error: Please enter in format: distance,fuel[,unit]"
            return
        }
        
        guard let distance = Double(components[0].trimmingCharacters(in: .whitespacesAndNewlines)),
              let fuel = Double(components[1].trimmingCharacters(in: .whitespacesAndNewlines)) else {
            result = "Error: Invalid numbers"
            return
        }
        
        let unit = components.count > 2 ? components[2].trimmingCharacters(in: .whitespacesAndNewlines) : "mpg"
        
        if unit.lowercased() == "mpg" {
            let mpg = distance / fuel
            let lper100km = 235.214 / mpg // Convert MPG to L/100km
            
            result = """
            \(String(format: "%.2f", mpg)) MPG
            \(String(format: "%.2f", lper100km)) L/100km
            """
            
            steps = [
                "Distance: \(distance) miles",
                "Fuel used: \(fuel) gallons",
                "Calculation: \(distance) ÷ \(fuel) = \(String(format: "%.2f", mpg)) MPG",
                "Converting to L/100km: 235.214 ÷ \(String(format: "%.2f", mpg)) = \(String(format: "%.2f", lper100km)) L/100km"
            ]
        } else {
            let lper100km = (fuel / distance) * 100
            let mpg = 235.214 / lper100km // Convert L/100km to MPG
            
            result = """
            \(String(format: "%.2f", lper100km)) L/100km
            \(String(format: "%.2f", mpg)) MPG
            """
            
            steps = [
                "Distance: \(distance) km",
                "Fuel used: \(fuel) liters",
                "Calculation: (\(fuel) ÷ \(distance)) × 100 = \(String(format: "%.2f", lper100km)) L/100km",
                "Converting to MPG: 235.214 ÷ \(String(format: "%.2f", lper100km)) = \(String(format: "%.2f", mpg)) MPG"
            ]
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
    
    func submitAIQuery(_ query: String, completion: @escaping (AIResponse?, Error?) -> Void) {
        // This would connect to the AI service based on selected provider
        // Mocking the response for demo purposes
        
        // Check if API key is required and provided
        if aiSettings.selectedProvider.requiresAPIKey && aiSettings.apiKey.isEmpty {
            completion(nil, NSError(domain: "AIProvider", code: 401, userInfo: [NSLocalizedDescriptionKey: "API key required"]))
            return
        }
        
        // Simulate network delay
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.5) {
            // Simple example for demo - in a real app, this would make API calls to the selected provider
            if query.contains("solve") {
                let response = AIResponse(
                    result: "x = 2 or x = -2",
                    steps: [
                        "Starting with the equation: x² - 4 = 0",
                        "Adding 4 to both sides: x² = 4",
                        "Taking square root of both sides: x = ±2",
                        "Therefore, x = 2 or x = -2"
                    ]
                )
                completion(response, nil)
            } else if query.contains("explain") {
                let response = AIResponse(
                    result: "The quadratic formula is used to solve quadratic equations in the form ax² + bx + c = 0.",
                    steps: [
                        "For any quadratic equation ax² + bx + c = 0:",
                        "The solutions are given by: x = (-b ± √(b² - 4ac)) / 2a",
                        "The term b² - 4ac is called the discriminant:",
                        "  • If b² - 4ac > 0: Two real solutions",
                        "  • If b² - 4ac = 0: One real solution (repeated)",
                        "  • If b² - 4ac < 0: Two complex solutions"
                    ]
                )
                completion(response, nil)
            } else {
                let response = AIResponse(
                    result: "I'll help you solve this problem step-by-step. What specific mathematical concept would you like me to explain?",
                    steps: [
                        "Try asking me to:",
                        "- Solve an equation",
                        "- Explain a mathematical concept",
                        "- Generate practice problems",
                        "- Break down a complex calculation"
                    ]
                )
                completion(response, nil)
            }
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
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "$\(String(format: "%.2f", value))"
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
    
    private func compoundingFrequencyName(_ frequency: Int) -> String {
        switch frequency {
        case 1: return "Annually"
        case 2: return "Semi-annually"
        case 4: return "Quarterly"
        case 12: return "Monthly"
        case 365: return "Daily"
        default: return "\(frequency) times per year"
        }
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
    
    func switchAIProvider(to provider: AIProvider) {
        aiSettings.selectedProvider = provider
        aiSettings.selectedModel = provider.defaultModel
    }
    
    func switchFinanceCalculator(to calculator: FinanceCalculatorType) {
        selectedFinanceCalculator = calculator
        // Reset the result when switching calculator modes
        result = ""
        steps = []
    }
}

struct HistoryEntry: Identifiable {
    let id: UUID
    let input: String
    let result: String
    let mode: CalculatorMode
    let timestamp: Date
}

struct AIResponse {
    let result: String
    let steps: [String]
}
