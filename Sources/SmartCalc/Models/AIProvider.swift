// filepath: c:\Users\Yaseen\Documents\projects\SmartCalc\Sources\SmartCalc\Models\AIProvider.swift
import Foundation

enum AIProvider: String, CaseIterable, Identifiable {
    case openAI = "OpenAI"
    case googleGemini = "Google Gemini"
    case anthropic = "Anthropic Claude"
    case local = "Local Model"
    case custom = "Custom"
    
    var id: String { rawValue }
    
    var models: [AIModel] {
        switch self {
        case .openAI:
            return [
                AIModel(id: "gpt-4o", name: "GPT-4o", provider: self),
                AIModel(id: "gpt-4", name: "GPT-4", provider: self),
                AIModel(id: "gpt-3.5-turbo", name: "GPT-3.5 Turbo", provider: self)
            ]
        case .googleGemini:
            return [
                AIModel(id: "gemini-pro", name: "Gemini Pro", provider: self),
                AIModel(id: "gemini-flash", name: "Gemini Flash", provider: self)
            ]
        case .anthropic:
            return [
                AIModel(id: "claude-3-opus", name: "Claude 3 Opus", provider: self),
                AIModel(id: "claude-3-sonnet", name: "Claude 3 Sonnet", provider: self),
                AIModel(id: "claude-3-haiku", name: "Claude 3 Haiku", provider: self)
            ]
        case .local:
            return [
                AIModel(id: "math-assistant", name: "Math Assistant (Lite)", provider: self)
            ]
        case .custom:
            return [
                AIModel(id: "custom", name: "Custom Endpoint", provider: self)
            ]
        }
    }
    
    var iconName: String {
        switch self {
        case .openAI: return "openai"
        case .googleGemini: return "google"
        case .anthropic: return "anthropic" 
        case .local: return "cpu"
        case .custom: return "network"
        }
    }
    
    var requiresAPIKey: Bool {
        switch self {
        case .local: return false
        default: return true
        }
    }
    
    var defaultModel: AIModel {
        models.first!
    }
}

struct AIModel: Identifiable, Hashable {
    let id: String
    let name: String
    let provider: AIProvider
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(provider.rawValue)
    }
    
    static func == (lhs: AIModel, rhs: AIModel) -> Bool {
        lhs.id == rhs.id && lhs.provider == rhs.provider
    }
}

struct AISettings {
    var selectedProvider: AIProvider = .openAI
    var selectedModel: AIModel = .openAI.defaultModel
    var apiKey: String = ""
    var customEndpoint: String = ""
    var showStepByStep: Bool = true
    var includeExplanations: Bool = true
    var generatePracticeProblems: Bool = false
    var temperatureValue: Double = 0.7
    var maxTokens: Int = 2048
}