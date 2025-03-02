# SmartCalc

A powerful iOS calculator app built with SwiftUI that goes far beyond basic arithmetic. Featuring advanced mathematical computations, matrix operations, graphing capabilities, and comprehensive unit conversions.

## Features

### Basic Mode
- Natural equation parsing (e.g., "2x + 3 = 7")
- Percentage calculations with context (e.g., "20% of 50")
- Variable storage with reuse (e.g., "tax = 0.08")
- Real-time calculation as you type
- Expression history with recall

### Scientific Mode
- **Advanced Math Functions**
  - Trigonometric: sin, cos, tan, and their inverses
  - Hyperbolic: sinh, cosh, tanh, and inverses
  - Logarithmic: ln, log, log2, log10
  - Special: gamma, erf, beta functions
- **Complex Number Support**
  - Basic operations with complex numbers
  - Polar and rectangular forms
  - Complex roots and powers
- **Mathematical Constants**
  - π (pi), e (euler's number)
  - φ (golden ratio)
  - γ (euler-mascheroni constant)

### AI-Powered Features
- **Smart Calculation Assistant**
  - Natural language problem solving
  - Step-by-step solution breakdowns
  - Mathematical concept explanations
- **AI Model Selection**
  - OpenAI integration (GPT-4, GPT-3.5)
  - Google Gemini support
  - Local on-device models for privacy
  - Custom API endpoint configuration
- **Smart Formula Recognition**
  - Camera-based equation scanning
  - Handwritten math recognition
  - OCR for printed formulas
- **Learning Recommendations**
  - Personalized concept explanations
  - Related formula suggestions
  - Practice problem generation

### Finance & QOL Tools
- **Loan & Mortgage Calculators**
  - Payment schedules with amortization tables
  - Interest rate comparisons
  - Early payoff scenarios
  - Affordability analysis
- **Investment Tools**
  - Compound interest calculator
  - Stock return estimator
  - Retirement savings planner
  - Tax-advantaged account modeling
- **Practical Daily Calculators**
  - Tip calculator with bill splitting
  - Discount and sale price finder
  - Fuel efficiency tracker
  - Currency exchange with live rates
  - Date calculators (days between dates, workdays)

### Matrix Mode
- **Matrix Operations**
  - Addition, subtraction, multiplication
  - Determinant and inverse
  - Eigenvalues and eigenvectors
  - Matrix transformations
- **Visual Matrix Editor**
  - Interactive matrix input
  - Size adjustment
  - Quick operations

### Graphing Mode
- **2D/3D Function Plotting**
  - Multiple function overlay
  - Customizable plot range
  - Grid and axis controls
- **Analysis Tools**
  - Find intersections
  - Calculate derivatives
  - Plot tangent lines
  - Area under curve

### Statistics Mode
- **Descriptive Statistics**
  - Mean, median, mode
  - Standard deviation, variance
  - Quartiles, IQR
- **Data Analysis**
  - Linear regression
  - Polynomial fitting
  - Distribution analysis
- **Data Visualization**
  - Histograms
  - Box plots
  - Scatter plots

### Programmer Mode
- **Number Base Conversion**
  - Binary, octal, decimal, hexadecimal
  - Signed and unsigned integers
- **Bitwise Operations**
  - AND, OR, XOR, NOT
  - Bit shifts and rotations
  - Bit field extraction
- **Advanced Features**
  - ASCII table reference
  - IEEE 754 float analysis
  - Binary arithmetic

### Unit Converter
- **Multiple Categories**
  - Length (including astronomical units)
  - Weight/Mass
  - Temperature
  - Time (including Unix timestamps)
  - Volume
  - Digital Storage
  - Speed
- **Smart Features**
  - Natural language parsing
  - Automatic unit detection
  - Favorite conversions
  - Bulk conversion

## Technical Features

- **Modern Swift Implementation**
  - Swift 5.5+ concurrency
  - Comprehensive test coverage
  - SwiftUI with iOS 15 features
  - MVVM architecture

- **Advanced Parsing**
  - Natural language expression parsing
  - Custom operator precedence
  - Error recovery and suggestions

- **AI Integration**
  - Configurable AI providers
  - Model switching based on task complexity
  - Fallback to on-device processing for offline use
  - Secure API key management

- **Performance**
  - Efficient algorithms for large calculations
  - Lazy evaluation where possible
  - Background processing for complex operations

- **User Experience**
  - Dark/light mode support
  - Dynamic type support
  - VoiceOver accessibility
  - iPadOS pointer support
  - Keyboard shortcuts

## Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+

## Installation

1. Clone the repository
```bash
git clone https://github.com/yourusername/SmartCalc.git
```

2. Install dependencies
```bash
cd SmartCalc
swift package resolve
```

3. Open in Xcode
```bash
xed .
```

## Architecture

### Core Components
- **ExpressionCalculator**: Advanced mathematical parser and evaluator
- **EquationSolver**: Symbolic mathematics engine
- **MatrixEngine**: Matrix operations processor
- **GraphingEngine**: Function plotting system
- **StatisticsEngine**: Statistical analysis tools
- **UnitConverter**: Comprehensive unit conversion system

### UI Layer
- **SmartCalcApp**: Main app coordinator
- **CalculatorView**: Primary user interface
- **GraphingView**: Interactive plotting interface
- **MatrixView**: Matrix manipulation interface
- **SettingsView**: App configuration

### View Models
- **CalculatorViewModel**: Core calculation logic
- **GraphViewModel**: Graphing logic
- **MatrixViewModel**: Matrix operations
- **StatisticsViewModel**: Statistical computations

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Swift Numerics for advanced mathematical operations
- Swift Algorithms for efficient computations
- SwiftStats for statistical analysis
- Swift Collections for optimized data structures
- PointFree's Parsing for expression parsing