// filepath: c:\Users\Yaseen\Documents\projects\SmartCalc\Sources\SmartCalc\Views\FinanceView.swift
import SwiftUI

struct FinanceView: View {
    @EnvironmentObject private var viewModel: CalculatorViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            // Finance calculator type selector
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(FinanceCalculatorType.allCases) { calculatorType in
                        FinanceTypeButton(
                            type: calculatorType,
                            isSelected: viewModel.selectedFinanceCalculator == calculatorType
                        ) {
                            viewModel.switchFinanceCalculator(to: calculatorType)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 10)
            
            // Current calculator view
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    switch viewModel.selectedFinanceCalculator {
                    case .mortgage, .loanPayment:
                        MortgageCalculatorView()
                    case .investment, .compoundInterest:
                        InvestmentCalculatorView()
                    case .retirement:
                        RetirementCalculatorView()
                    case .tipCalculator:
                        TipCalculatorView()
                    case .discount:
                        DiscountCalculatorView()
                    case .fuelEfficiency:
                        FuelEfficiencyCalculatorView()
                    case .currencyExchange:
                        CurrencyExchangeView()
                    case .dateCalculator:
                        DateCalculatorView()
                    }
                }
                .padding()
            }
        }
    }
}

struct FinanceTypeButton: View {
    let type: FinanceCalculatorType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: type.icon)
                    .font(.system(size: 24))
                    .frame(height: 30)
                
                Text(type.id)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(width: 80)
            .padding(.vertical, 10)
            .background(isSelected ? Color.blue.opacity(0.2) : Color.clear)
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}

struct MortgageCalculatorView: View {
    @EnvironmentObject private var viewModel: CalculatorViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Mortgage Calculator")
                .font(.headline)
            
            Group {
                HStack {
                    Text("Loan Amount")
                    Spacer()
                    TextField("Amount", value: $viewModel.loanAmount, formatter: NumberFormatter.currencyFormatter)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 150)
                }
                
                HStack {
                    Text("Interest Rate (%)")
                    Spacer()
                    TextField("Rate", value: $viewModel.interestRate, formatter: NumberFormatter.percentFormatter)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 150)
                }
                
                HStack {
                    Text("Loan Term (years)")
                    Spacer()
                    Picker("", selection: $viewModel.loanTermYears) {
                        ForEach([10, 15, 20, 25, 30], id: \.self) { year in
                            Text("\(year) years").tag(year)
                        }
                    }
                    .frame(width: 150)
                }
            }
            
            Button("Calculate") {
                viewModel.calculate()
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)
            .padding(.top, 10)
            
            if !viewModel.result.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Results")
                        .font(.headline)
                    
                    Text(viewModel.result)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
                
                if !viewModel.amortizationSchedule.isEmpty {
                    NavigationLink("View Amortization Schedule") {
                        AmortizationScheduleView()
                    }
                    .padding(.top, 10)
                }
            }
        }
    }
}

struct AmortizationScheduleView: View {
    @EnvironmentObject private var viewModel: CalculatorViewModel
    
    var body: some View {
        List {
            Section(header: Text("Payment Schedule")) {
                ForEach(Array(viewModel.amortizationSchedule.prefix(120).enumerated()), id: \.element.period) { index, entry in
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Payment \(entry.period)")
                                .font(.headline)
                            Spacer()
                            Text(formatCurrency(entry.payment))
                        }
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Principal")
                                Text(formatCurrency(entry.principal))
                                    .foregroundColor(.blue)
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text("Interest")
                                Text(formatCurrency(entry.interest))
                                    .foregroundColor(.red)
                            }
                        }
                        .font(.subheadline)
                        .padding(.top, 1)
                        
                        Text("Remaining Balance: \(formatCurrency(entry.remainingBalance))")
                            .font(.footnote)
                            .padding(.top, 1)
                    }
                    .padding(.vertical, 4)
                }
            }
            
            if viewModel.amortizationSchedule.count > 120 {
                Section {
                    Text("Showing first 10 years of payments")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Amortization Schedule")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "$\(String(format: "%.2f", value))"
    }
}

struct InvestmentCalculatorView: View {
    @EnvironmentObject private var viewModel: CalculatorViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Investment Calculator")
                .font(.headline)
            
            Group {
                HStack {
                    Text("Initial Investment")
                    Spacer()
                    TextField("Amount", value: $viewModel.principal, formatter: NumberFormatter.currencyFormatter)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 150)
                }
                
                HStack {
                    Text("Annual Return (%)")
                    Spacer()
                    TextField("Rate", value: $viewModel.annualReturnRate, formatter: NumberFormatter.percentFormatter)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 150)
                }
                
                HStack {
                    Text("Monthly Contribution")
                    Spacer()
                    TextField("Amount", value: $viewModel.monthlyContribution, formatter: NumberFormatter.currencyFormatter)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 150)
                }
                
                HStack {
                    Text("Years")
                    Spacer()
                    Stepper("\(viewModel.investmentYears) years", value: $viewModel.investmentYears, in: 1...50)
                }
                
                HStack {
                    Text("Compound Frequency")
                    Spacer()
                    Picker("", selection: $viewModel.compoundingFrequency) {
                        Text("Annually").tag(1)
                        Text("Semi-annually").tag(2)
                        Text("Quarterly").tag(4)
                        Text("Monthly").tag(12)
                        Text("Daily").tag(365)
                    }
                    .frame(width: 150)
                }
            }
            
            Button("Calculate") {
                viewModel.calculate()
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)
            .padding(.top, 10)
            
            if !viewModel.result.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Results")
                        .font(.headline)
                    
                    Text(viewModel.result)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
            }
        }
    }
}

struct RetirementCalculatorView: View {
    @EnvironmentObject private var viewModel: CalculatorViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Retirement Calculator")
                .font(.headline)
            
            // Same fields as investment calculator
            Group {
                HStack {
                    Text("Current Savings")
                    Spacer()
                    TextField("Amount", value: $viewModel.principal, formatter: NumberFormatter.currencyFormatter)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 150)
                }
                
                HStack {
                    Text("Expected Return (%)")
                    Spacer()
                    TextField("Rate", value: $viewModel.annualReturnRate, formatter: NumberFormatter.percentFormatter)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 150)
                }
                
                HStack {
                    Text("Monthly Contribution")
                    Spacer()
                    TextField("Amount", value: $viewModel.monthlyContribution, formatter: NumberFormatter.currencyFormatter)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 150)
                }
                
                HStack {
                    Text("Years Until Retirement")
                    Spacer()
                    Stepper("\(viewModel.investmentYears) years", value: $viewModel.investmentYears, in: 1...50)
                }
            }
            
            Button("Calculate") {
                viewModel.calculate()
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)
            .padding(.top, 10)
            
            if !viewModel.result.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Results")
                        .font(.headline)
                    
                    Text(viewModel.result)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
            }
        }
    }
}

struct TipCalculatorView: View {
    @EnvironmentObject private var viewModel: CalculatorViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Tip Calculator")
                .font(.headline)
            
            Group {
                HStack {
                    Text("Bill Amount")
                    Spacer()
                    TextField("Amount", value: $viewModel.billAmount, formatter: NumberFormatter.currencyFormatter)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 150)
                }
                
                HStack {
                    Text("Tip Percentage")
                    Spacer()
                    HStack(spacing: 0) {
                        Slider(value: $viewModel.tipPercentage, in: 0...30, step: 1)
                            .frame(width: 100)
                        Text(" \(Int(viewModel.tipPercentage))%")
                            .frame(width: 50, alignment: .trailing)
                    }
                }
                
                HStack {
                    Text("Number of People")
                    Spacer()
                    Stepper("\(viewModel.numberOfPeople)", value: $viewModel.numberOfPeople, in: 1...20)
                        .frame(width: 150)
                }
            }
            
            Button("Calculate") {
                viewModel.calculate()
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)
            .padding(.top, 10)
            
            if !viewModel.result.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Results")
                        .font(.headline)
                    
                    Text(viewModel.result)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
            }
        }
    }
}

struct DiscountCalculatorView: View {
    @EnvironmentObject private var viewModel: CalculatorViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Discount Calculator")
                .font(.headline)
            
            Group {
                HStack {
                    Text("Original Price")
                    Spacer()
                    TextField("Price", value: $viewModel.originalPrice, formatter: NumberFormatter.currencyFormatter)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 150)
                }
                
                HStack {
                    Text("Discount (%)")
                    Spacer()
                    HStack(spacing: 0) {
                        Slider(value: $viewModel.discountPercentage, in: 0...100, step: 5)
                            .frame(width: 100)
                        Text(" \(Int(viewModel.discountPercentage))%")
                            .frame(width: 50, alignment: .trailing)
                    }
                }
                
                HStack {
                    Text("Tax Rate (%)")
                    Spacer()
                    TextField("Tax", value: $viewModel.taxRate, formatter: NumberFormatter.percentFormatter)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 150)
                }
            }
            
            Button("Calculate") {
                viewModel.calculate()
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)
            .padding(.top, 10)
            
            if !viewModel.result.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Results")
                        .font(.headline)
                    
                    Text(viewModel.result)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
            }
        }
    }
}

struct FuelEfficiencyCalculatorView: View {
    @EnvironmentObject private var viewModel: CalculatorViewModel
    @State private var distance: String = "100"
    @State private var fuel: String = "5"
    @State private var unit: String = "mpg"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Fuel Efficiency Calculator")
                .font(.headline)
            
            Group {
                HStack {
                    Text("Distance")
                    Spacer()
                    TextField("Distance", text: $distance)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 100)
                    
                    Text(unit == "mpg" ? "miles" : "km")
                        .frame(width: 50)
                }
                
                HStack {
                    Text("Fuel Used")
                    Spacer()
                    TextField("Fuel", text: $fuel)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 100)
                    
                    Text(unit == "mpg" ? "gallons" : "liters")
                        .frame(width: 50)
                }
                
                Picker("Unit System", selection: $unit) {
                    Text("MPG (US)").tag("mpg")
                    Text("L/100km").tag("l/100km")
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            Button("Calculate") {
                // Format input for the calculator
                viewModel.input = "\(distance),\(fuel),\(unit)"
                viewModel.calculate()
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)
            .padding(.top, 10)
            
            if !viewModel.result.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Results")
                        .font(.headline)
                    
                    Text(viewModel.result)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
            }
        }
    }
}

struct CurrencyExchangeView: View {
    @EnvironmentObject private var viewModel: CalculatorViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Currency Exchange")
                .font(.headline)
            
            Group {
                HStack {
                    Text("Amount")
                    Spacer()
                    TextField("Amount", value: $viewModel.exchangeAmount, formatter: NumberFormatter.currencyFormatter)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 150)
                }
                
                HStack {
                    Text("From Currency")
                    Spacer()
                    TextField("From", text: $viewModel.fromCurrency)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 150)
                }
                
                HStack {
                    Text("To Currency")
                    Spacer()
                    TextField("To", text: $viewModel.toCurrency)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 150)
                }
                
                HStack {
                    Text("Exchange Rate")
                    Spacer()
                    TextField("Rate", value: $viewModel.exchangeRate, formatter: NumberFormatter.decimalFormatter)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 150)
                }
            }
            
            Button("Calculate") {
                viewModel.calculate()
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)
            .padding(.top, 10)
            
            if !viewModel.result.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Results")
                        .font(.headline)
                    
                    Text(viewModel.result)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
            }
        }
    }
}

struct DateCalculatorView: View {
    @EnvironmentObject private var viewModel: CalculatorViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Date Calculator")
                .font(.headline)
            
            Group {
                DatePicker("Start Date", selection: $viewModel.startDate, displayedComponents: .date)
                
                DatePicker("End Date", selection: $viewModel.endDate, displayedComponents: .date)
                
                Toggle("Count Business Days Only", isOn: $viewModel.countWeekdaysOnly)
            }
            
            Button("Calculate") {
                viewModel.calculate()
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)
            .padding(.top, 10)
            
            if !viewModel.result.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Results")
                        .font(.headline)
                    
                    Text(viewModel.result)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
            }
        }
    }
}

// Helper formatters
extension NumberFormatter {
    static var currencyFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        return formatter
    }
    
    static var percentFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter
    }
    
    static var decimalFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 4
        return formatter
    }
}