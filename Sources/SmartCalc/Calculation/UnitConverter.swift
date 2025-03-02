import Foundation

class UnitConverter {
    enum UnitType: String, CaseIterable {
        case length
        case weight
        case temperature
        case time
        case volume
        case digitalStorage
        case speed
        
        var displayName: String {
            switch self {
            case .length: return "Length"
            case .weight: return "Weight"
            case .temperature: return "Temperature"
            case .time: return "Time"
            case .volume: return "Volume"
            case .digitalStorage: return "Digital Storage"
            case .speed: return "Speed"
            }
        }
    }
    
    enum LengthUnit: String, CaseIterable {
        case meters = "m"
        case feet = "ft"
        case inches = "in"
        case centimeters = "cm"
        case kilometers = "km"
        case miles = "mi"
        case yards = "yd"
        case nanometers = "nm"
        case micrometers = "μm"
        case millimeters = "mm"
        case lightyears = "ly"
        
        var toMeters: Double {
            switch self {
            case .meters: return 1
            case .feet: return 0.3048
            case .inches: return 0.0254
            case .centimeters: return 0.01
            case .kilometers: return 1000
            case .miles: return 1609.344
            case .yards: return 0.9144
            case .nanometers: return 1e-9
            case .micrometers: return 1e-6
            case .millimeters: return 0.001
            case .lightyears: return 9.461e15
            }
        }
    }
    
    enum WeightUnit: String, CaseIterable {
        case kilograms = "kg"
        case pounds = "lb"
        case grams = "g"
        case ounces = "oz"
        case tons = "t"
        case milligrams = "mg"
        case micrograms = "μg"
        case stonePounds = "st"
        
        var toKilograms: Double {
            switch self {
            case .kilograms: return 1
            case .pounds: return 0.45359237
            case .grams: return 0.001
            case .ounces: return 0.0283495
            case .tons: return 1000
            case .milligrams: return 1e-6
            case .micrograms: return 1e-9
            case .stonePounds: return 6.35029318
            }
        }
    }
    
    enum TemperatureUnit: String, CaseIterable {
        case celsius = "C"
        case fahrenheit = "F"
        case kelvin = "K"
        
        func convert(_ value: Double, to targetUnit: TemperatureUnit) -> Double {
            // First convert to Celsius
            let celsius: Double
            switch self {
            case .celsius:
                celsius = value
            case .fahrenheit:
                celsius = (value - 32) * 5/9
            case .kelvin:
                celsius = value - 273.15
            }
            
            // Then convert to target unit
            switch targetUnit {
            case .celsius:
                return celsius
            case .fahrenheit:
                return celsius * 9/5 + 32
            case .kelvin:
                return celsius + 273.15
            }
        }
    }
    
    enum TimeUnit: String, CaseIterable {
        case seconds = "s"
        case minutes = "min"
        case hours = "h"
        case days = "d"
        case weeks = "w"
        case months = "mo"
        case years = "y"
        case milliseconds = "ms"
        case microseconds = "μs"
        case nanoseconds = "ns"
        
        var toSeconds: Double {
            switch self {
            case .seconds: return 1
            case .minutes: return 60
            case .hours: return 3600
            case .days: return 86400
            case .weeks: return 604800
            case .months: return 2592000  // Average month (30 days)
            case .years: return 31536000  // Non-leap year
            case .milliseconds: return 0.001
            case .microseconds: return 1e-6
            case .nanoseconds: return 1e-9
            }
        }
    }
    
    enum VolumeUnit: String, CaseIterable {
        case liters = "L"
        case milliliters = "mL"
        case cubicMeters = "m³"
        case gallons = "gal"
        case quarts = "qt"
        case pints = "pt"
        case cups = "cup"
        case fluidOunces = "fl oz"
        case tablespoons = "tbsp"
        case teaspoons = "tsp"
        
        var toLiters: Double {
            switch self {
            case .liters: return 1
            case .milliliters: return 0.001
            case .cubicMeters: return 1000
            case .gallons: return 3.78541
            case .quarts: return 0.946353
            case .pints: return 0.473176
            case .cups: return 0.236588
            case .fluidOunces: return 0.0295735
            case .tablespoons: return 0.0147868
            case .teaspoons: return 0.00492892
            }
        }
    }
    
    enum DigitalStorageUnit: String, CaseIterable {
        case bytes = "B"
        case kilobytes = "KB"
        case megabytes = "MB"
        case gigabytes = "GB"
        case terabytes = "TB"
        case petabytes = "PB"
        case bits = "bit"
        
        var toBytes: Double {
            switch self {
            case .bytes: return 1
            case .kilobytes: return 1024
            case .megabytes: return 1024 * 1024
            case .gigabytes: return 1024 * 1024 * 1024
            case .terabytes: return 1024 * 1024 * 1024 * 1024
            case .petabytes: return 1024 * 1024 * 1024 * 1024 * 1024
            case .bits: return 0.125
            }
        }
    }
    
    enum SpeedUnit: String, CaseIterable {
        case metersPerSecond = "m/s"
        case kilometersPerHour = "km/h"
        case milesPerHour = "mph"
        case knots = "kn"
        case mach = "M"
        case feetPerSecond = "ft/s"
        
        var toMetersPerSecond: Double {
            switch self {
            case .metersPerSecond: return 1
            case .kilometersPerHour: return 0.277778
            case .milesPerHour: return 0.44704
            case .knots: return 0.514444
            case .mach: return 343  // At sea level, 20°C
            case .feetPerSecond: return 0.3048
            }
        }
    }
    
    func convert(_ value: Double, from fromUnit: String, to toUnit: String) throws -> (Double, [String]) {
        var steps: [String] = []
        steps.append("Converting \(value) \(fromUnit) to \(toUnit)")
        
        // Try each unit type
        if let result = try? convertLength(value, from: fromUnit, to: toUnit) {
            return result
        }
        if let result = try? convertWeight(value, from: fromUnit, to: toUnit) {
            return result
        }
        if let result = try? convertTemperature(value, from: fromUnit, to: toUnit) {
            return result
        }
        if let result = try? convertTime(value, from: fromUnit, to: toUnit) {
            return result
        }
        if let result = try? convertVolume(value, from: fromUnit, to: toUnit) {
            return result
        }
        if let result = try? convertDigitalStorage(value, from: fromUnit, to: toUnit) {
            return result
        }
        if let result = try? convertSpeed(value, from: fromUnit, to: toUnit) {
            return result
        }
        
        throw ConversionError.unsupportedUnits
    }
    
    // Individual conversion methods for each unit type...
    private func convertLength(_ value: Double, from fromStr: String, to toStr: String) throws -> (Double, [String]) {
        guard let fromUnit = LengthUnit(rawValue: fromStr),
              let toUnit = LengthUnit(rawValue: toStr) else {
            throw ConversionError.unsupportedUnits
        }
        
        var steps: [String] = []
        let meters = value * fromUnit.toMeters
        steps.append("Converting to meters: \(value) \(fromUnit.rawValue) = \(meters) m")
        
        let result = meters / toUnit.toMeters
        steps.append("Converting to \(toUnit.rawValue): \(meters) m = \(result) \(toUnit.rawValue)")
        
        return (result, steps)
    }
    
    // Similar implementation for other conversion methods...
    
    func parseConversionExpression(_ expression: String) throws -> (Double, String, String) {
        // Format: "5.2 ft to m" or "5.2ft to m"
        let components = expression.components(separatedBy: " to ")
        guard components.count == 2 else {
            throw ConversionError.invalidFormat
        }
        
        let fromPart = components[0].trimmingCharacters(in: .whitespaces)
        let toUnit = components[1].trimmingCharacters(in: .whitespaces)
        
        // Extract number and unit from the first part
        var numberStr = ""
        var fromUnit = ""
        var foundNumber = false
        
        for char in fromPart {
            if char.isNumber || char == "." {
                numberStr.append(char)
                foundNumber = true
            } else if !char.isWhitespace {
                fromUnit.append(char)
            }
        }
        
        guard foundNumber,
              let value = Double(numberStr),
              !fromUnit.isEmpty else {
            throw ConversionError.invalidFormat
        }
        
        return (value, fromUnit, toUnit)
    }
    
    static func getAllUnits() -> [(UnitType, [String])] {
        [
            (.length, LengthUnit.allCases.map { $0.rawValue }),
            (.weight, WeightUnit.allCases.map { $0.rawValue }),
            (.temperature, TemperatureUnit.allCases.map { $0.rawValue }),
            (.time, TimeUnit.allCases.map { $0.rawValue }),
            (.volume, VolumeUnit.allCases.map { $0.rawValue }),
            (.digitalStorage, DigitalStorageUnit.allCases.map { $0.rawValue }),
            (.speed, SpeedUnit.allCases.map { $0.rawValue })
        ]
    }
}

enum ConversionError: Error, LocalizedError {
    case unsupportedUnits
    case invalidFormat
    case invalidValue
    
    var errorDescription: String? {
        switch self {
        case .unsupportedUnits:
            return "Unsupported units for conversion"
        case .invalidFormat:
            return "Invalid conversion format. Use format: '5.2 ft to m'"
        case .invalidValue:
            return "Invalid value for conversion"
        }
    }
}