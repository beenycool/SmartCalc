// filepath: c:\Users\Yaseen\Documents\projects\SmartCalc\Sources\SmartCalc\Models\FinanceCalculator.swift
import Foundation

enum FinanceCalculatorType: String, CaseIterable, Identifiable {
    case mortgage = "Mortgage"
    case loanPayment = "Loan Payment"
    case investment = "Investment"
    case compoundInterest = "Compound Interest"
    case retirement = "Retirement"
    case tipCalculator = "Tip Calculator"
    case discount = "Discount"
    case fuelEfficiency = "Fuel Efficiency"
    case currencyExchange = "Currency Exchange"
    case dateCalculator = "Date Calculator"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .mortgage: return "house.fill"
        case .loanPayment: return "creditcard.fill"
        case .investment: return "chart.line.uptrend.xyaxis"
        case .compoundInterest: return "dollarsign.arrow.circlepath"
        case .retirement: return "figure.mind.and.body"
        case .tipCalculator: return "fork.knife"
        case .discount: return "tag.fill"
        case .fuelEfficiency: return "fuelpump.fill"
        case .currencyExchange: return "dollarsign.circle"
        case .dateCalculator: return "calendar"
        }
    }
    
    var description: String {
        switch self {
        case .mortgage:
            return "Calculate mortgage payments, amortization schedules, and affordability."
        case .loanPayment:
            return "Calculate loan payments, interest costs, and early payoff options."
        case .investment:
            return "Estimate investment returns and portfolio growth."
        case .compoundInterest:
            return "Calculate growth of investments with compounding interest."
        case .retirement:
            return "Plan for retirement with savings simulations and goals."
        case .tipCalculator:
            return "Calculate tips and split bills among multiple people."
        case .discount:
            return "Calculate sale prices, savings, and percentage discounts."
        case .fuelEfficiency:
            return "Track vehicle fuel economy and calculate trip costs."
        case .currencyExchange:
            return "Convert between different currencies with live exchange rates."
        case .dateCalculator:
            return "Calculate days between dates, add/subtract time periods."
        }
    }
}

class MortgageCalculator {
    func calculateMonthlyPayment(loanAmount: Double, interestRate: Double, loanTermYears: Int) -> Double {
        let monthlyRate = interestRate / 100 / 12
        let numberOfPayments = Double(loanTermYears * 12)
        
        // Handle edge case where interest rate is zero
        if interestRate == 0 {
            return loanAmount / numberOfPayments
        }
        
        // PMT formula: PMT = P × (r × (1 + r)^n) / ((1 + r)^n - 1)
        let payment = loanAmount * (monthlyRate * pow(1 + monthlyRate, numberOfPayments)) / (pow(1 + monthlyRate, numberOfPayments) - 1)
        
        return payment
    }
    
    func generateAmortizationSchedule(loanAmount: Double, interestRate: Double, loanTermYears: Int) -> [AmortizationEntry] {
        let monthlyRate = interestRate / 100 / 12
        let numberOfPayments = loanTermYears * 12
        let monthlyPayment = calculateMonthlyPayment(loanAmount: loanAmount, interestRate: interestRate, loanTermYears: loanTermYears)
        
        var schedule: [AmortizationEntry] = []
        var remainingBalance = loanAmount
        
        for period in 1...numberOfPayments {
            let interestPayment = remainingBalance * monthlyRate
            let principalPayment = monthlyPayment - interestPayment
            remainingBalance -= principalPayment
            
            // Create amortization entry
            let entry = AmortizationEntry(
                period: period,
                payment: monthlyPayment,
                principal: principalPayment,
                interest: interestPayment,
                remainingBalance: max(0, remainingBalance) // Ensure no negative balance due to rounding
            )
            
            schedule.append(entry)
        }
        
        return schedule
    }
}

struct AmortizationEntry {
    let period: Int
    let payment: Double
    let principal: Double
    let interest: Double
    let remainingBalance: Double
}

class CompoundInterestCalculator {
    func calculateFutureValue(principal: Double, annualRate: Double, years: Int, compoundingFrequency: Int, monthlyContribution: Double = 0) -> Double {
        let r = annualRate / 100.0
        let n = Double(compoundingFrequency)
        let t = Double(years)
        let pmt = monthlyContribution
        
        // For principal only: P(1 + r/n)^(nt)
        let futureValuePrincipal = principal * pow(1 + r/n, n * t)
        
        // For regular contributions: PMT × [(1 + r/n)^(nt) - 1] / (r/n)
        var futureValueContributions: Double = 0
        if monthlyContribution > 0 && r > 0 {
            // Convert annual rate to rate per compounding period
            let ratePerPeriod = r / n
            // Multiply by 12/n to adjust for monthly contributions when compounding frequency isn't monthly
            let periodsPerYear = 12.0 / n
            futureValueContributions = pmt * periodsPerYear * (pow(1 + ratePerPeriod, n * t) - 1) / ratePerPeriod
        } else if monthlyContribution > 0 {
            // If interest rate is 0, just add up the contributions
            futureValueContributions = monthlyContribution * 12 * t
        }
        
        return futureValuePrincipal + futureValueContributions
    }
}

class TipCalculator {
    func calculateTip(billAmount: Double, tipPercentage: Double, numberOfPeople: Int) -> (tipAmount: Double, totalAmount: Double, perPersonAmount: Double) {
        let tipAmount = billAmount * (tipPercentage / 100.0)
        let totalAmount = billAmount + tipAmount
        let perPersonAmount = totalAmount / Double(max(1, numberOfPeople))
        
        return (tipAmount, totalAmount, perPersonAmount)
    }
}

class DiscountCalculator {
    func calculateDiscountedPrice(originalPrice: Double, discountPercentage: Double, taxRate: Double = 0) -> (discountAmount: Double, savedAmount: Double, finalPrice: Double, taxAmount: Double) {
        let discountAmount = originalPrice * (discountPercentage / 100.0)
        let discountedPrice = originalPrice - discountAmount
        let taxAmount = discountedPrice * (taxRate / 100.0)
        let finalPrice = discountedPrice + taxAmount
        
        return (discountAmount, discountAmount, finalPrice, taxAmount)
    }
}

class CurrencyExchange {
    func convert(amount: Double, fromCurrency: String, toCurrency: String, exchangeRate: Double) -> Double {
        return amount * exchangeRate
    }
}

class DateCalculator {
    func daysBetween(startDate: Date, endDate: Date, countWeekdaysOnly: Bool = false) -> Int {
        let calendar = Calendar.current
        
        if countWeekdaysOnly {
            let days = calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 0
            var weekdays = 0
            
            for i in 0..<days {
                if let date = calendar.date(byAdding: .day, value: i, to: startDate) {
                    let weekday = calendar.component(.weekday, from: date)
                    if weekday != 1 && weekday != 7 {  // Not Sunday and not Saturday
                        weekdays += 1
                    }
                }
            }
            
            return weekdays
        } else {
            return calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 0
        }
    }
    
    func addTime(toDate: Date, years: Int = 0, months: Int = 0, days: Int = 0) -> Date {
        var components = DateComponents()
        components.year = years
        components.month = months
        components.day = days
        
        return Calendar.current.date(byAdding: components, to: toDate) ?? toDate
    }
}