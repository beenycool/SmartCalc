import Foundation

enum CalculatorMode: String, CaseIterable {
    case basic
    case scientific
    case converter
    case matrix
    case graph
    case programmer
    case statistics
    case ai
    case finance
    
    var displayName: String {
        switch self {
        case .basic:
            return "Basic"
        case .scientific:
            return "Scientific"
        case .converter:
            return "Converter"
        case .matrix:
            return "Matrix"
        case .graph:
            return "Graph"
        case .programmer:
            return "Programmer"
        case .statistics:
            return "Statistics"
        case .ai:
            return "AI Assistant"
        case .finance:
            return "Finance"
        }
    }
    
    var icon: String {
        switch self {
        case .basic:
            return "plus.slash.minus"
        case .scientific:
            return "function"
        case .converter:
            return "arrow.triangle.2.circlepath"
        case .matrix:
            return "square.grid.3x3"
        case .graph:
            return "waveform.path.ecg"
        case .programmer:
            return "number"
        case .statistics:
            return "chart.bar"
        case .ai:
            return "brain"
        case .finance:
            return "dollarsign.circle"
        }
    }
    
    var placeholder: String {
        switch self {
        case .basic:
            return "Enter calculation (e.g., 5 + 3)"
        case .scientific:
            return "Enter expression (e.g., sin(45) or log(100))"
        case .converter:
            return "Enter value to convert (e.g., 5.2 ft to m)"
        case .matrix:
            return "Enter matrix operation (e.g., [1,2;3,4] × [5,6;7,8])"
        case .graph:
            return "Enter function to graph (e.g., y = x^2)"
        case .programmer:
            return "Enter value (supports hex, binary, decimal)"
        case .statistics:
            return "Enter dataset (e.g., 1,2,3,4,5)"
        case .ai:
            return "Ask a math question (e.g., solve x^2 - 4 = 0)"
        case .finance:
            return "Select a calculator type below"
        }
    }
    
    var features: [Feature] {
        switch self {
        case .basic:
            return [
                .init(name: "Basic Arithmetic", description: "+, -, *, /"),
                .init(name: "Percentages", description: "Calculate percentages and discounts"),
                .init(name: "Memory", description: "Store and recall values"),
                .init(name: "Natural Input", description: "Type expressions naturally")
            ]
        case .scientific:
            return [
                .init(name: "Advanced Math", description: "Trigonometry, logarithms, complex numbers"),
                .init(name: "Constants", description: "π, e, φ, etc."),
                .init(name: "Unit Circle", description: "Visual angle reference"),
                .init(name: "Custom Functions", description: "Define your own functions")
            ]
        case .converter:
            return [
                .init(name: "Multiple Categories", description: "Length, weight, temperature, etc."),
                .init(name: "Smart Detection", description: "Automatic unit recognition"),
                .init(name: "Favorite Conversions", description: "Save frequent conversions"),
                .init(name: "Bulk Convert", description: "Convert multiple values at once")
            ]
        case .matrix:
            return [
                .init(name: "Matrix Operations", description: "Addition, multiplication, inverse"),
                .init(name: "Determinant", description: "Calculate matrix determinant"),
                .init(name: "Eigenvalues", description: "Find eigenvalues and eigenvectors"),
                .init(name: "Visual Editor", description: "Interactive matrix input")
            ]
        case .graph:
            return [
                .init(name: "2D/3D Plotting", description: "Plot functions and data"),
                .init(name: "Multiple Functions", description: "Compare different functions"),
                .init(name: "Zoom & Pan", description: "Interactive graph exploration"),
                .init(name: "Export", description: "Save graphs as images")
            ]
        case .programmer:
            return [
                .init(name: "Base Conversion", description: "Binary, octal, decimal, hex"),
                .init(name: "Bitwise Operations", description: "AND, OR, XOR, NOT"),
                .init(name: "Bit Shifting", description: "Left and right shifts"),
                .init(name: "ASCII Table", description: "Character code reference")
            ]
        case .statistics:
            return [
                .init(name: "Descriptive Stats", description: "Mean, median, mode, std dev"),
                .init(name: "Regression", description: "Linear, polynomial, exponential"),
                .init(name: "Distribution", description: "Normal, binomial, Poisson"),
                .init(name: "Visualization", description: "Histograms, box plots")
            ]
        case .ai:
            return [
                .init(name: "Smart Assistant", description: "Natural language problem solving"),
                .init(name: "Step-by-Step", description: "Detailed solution breakdowns"),
                .init(name: "Learning", description: "Concept explanations and practice problems"),
                .init(name: "Formula Recognition", description: "Scan equations with camera")
            ]
        case .finance:
            return [
                .init(name: "Loan Calculator", description: "Payment schedules and amortization"),
                .init(name: "Investment Tools", description: "Compound interest and returns"),
                .init(name: "Daily Calculators", description: "Tips, discounts, fuel efficiency"),
                .init(name: "Tax Planning", description: "Tax calculations and estimates")
            ]
        }
    }
    
    struct Feature: Identifiable {
        let id = UUID()
        let name: String
        let description: String
    }
    
    var supportedOperations: [String] {
        switch self {
        case .basic:
            return ["+", "-", "*", "/", "%", "="]
        case .scientific:
            return [
                "sin", "cos", "tan", "asin", "acos", "atan",
                "sinh", "cosh", "tanh", "asinh", "acosh", "atanh",
                "log", "ln", "log2", "log10",
                "sqrt", "cbrt", "^", "!", "π", "e"
            ]
        case .converter:
            return Array(UnitConverter.UnitType.allCases.map(\.rawValue))
        case .matrix:
            return ["det", "inv", "trans", "eigen", "+", "-", "×"]
        case .graph:
            return ["y=", "r=", "x=", "parametric"]
        case .programmer:
            return ["AND", "OR", "XOR", "NOT", "<<", ">>", "~"]
        case .statistics:
            return ["mean", "median", "mode", "stdev", "var", "sum"]
        case .ai:
            return ["explain", "solve", "practice", "scan"]
        case .finance:
            return ["mortgage", "investment", "tip", "discount", "currency", "date"]
        }
    }
}