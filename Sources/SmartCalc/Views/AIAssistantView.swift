// filepath: c:\Users\Yaseen\Documents\projects\SmartCalc\Sources\SmartCalc\Views\AIAssistantView.swift
import SwiftUI

struct AIAssistantView: View {
    @EnvironmentObject private var viewModel: CalculatorViewModel
    @State private var isShowingSettings = false
    
    var body: some View {
        VStack(spacing: 16) {
            // AI Provider Selection
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(AIProvider.allCases) { provider in
                        AIProviderButton(
                            provider: provider,
                            isSelected: viewModel.aiSettings.selectedProvider == provider,
                            hasAPIKey: !provider.requiresAPIKey || !viewModel.aiSettings.apiKey.isEmpty
                        ) {
                            viewModel.switchAIProvider(to: provider)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)
            
            // AI Query Input
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Ask a math question")
                        .font(.headline)
                    Spacer()
                    Button(action: {
                        isShowingSettings = true
                    }) {
                        Label("Settings", systemImage: "gear")
                            .font(.caption)
                    }
                    .buttonStyle(.borderless)
                }
                
                TextField("", text: $viewModel.input, axis: .vertical)
                    .lineLimit(5...10)
                    .textFieldStyle(.roundedBorder)
                    .placeholder(when: viewModel.input.isEmpty) {
                        Text("E.g., 'Solve x² - 4 = 0' or 'Explain the quadratic formula'")
                            .foregroundColor(.gray)
                    }
                
                HStack(spacing: 12) {
                    Button(action: {
                        viewModel.clearInput()
                    }) {
                        Text("Clear")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(viewModel.input.isEmpty)
                    
                    Button(action: {
                        viewModel.calculate()
                    }) {
                        Text("Ask AI")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.input.isEmpty || viewModel.isProcessingAIRequest)
                }
            }
            .padding(.horizontal)
            
            Divider()
            
            // Results display
            Group {
                if viewModel.isProcessingAIRequest {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Thinking...")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if !viewModel.result.isEmpty {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            // Answer section
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Answer")
                                    .font(.headline)
                                
                                Text(viewModel.result)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(8)
                            }
                            
                            // Steps section (if available)
                            if !viewModel.steps.isEmpty && viewModel.aiSettings.showStepByStep {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Step-by-step Solution")
                                        .font(.headline)
                                    
                                    ForEach(Array(viewModel.steps.enumerated()), id: \.offset) { index, step in
                                        HStack(alignment: .top) {
                                            Text("\(index + 1).")
                                                .font(.subheadline.bold())
                                                .frame(width: 25, alignment: .leading)
                                            Text(step)
                                                .font(.subheadline)
                                        }
                                        .padding(.vertical, 4)
                                    }
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            }
                            
                            // Attribution
                            Text("Powered by \(viewModel.aiSettings.selectedProvider.rawValue) \(viewModel.aiSettings.selectedModel.name)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .padding(.top, 8)
                        }
                        .padding()
                    }
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "brain")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("Ask me anything about math")
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Example queries:")
                                .font(.headline)
                            
                            ForEach(["Solve the equation 3x + 4 = 25",
                                    "Explain integration by parts",
                                    "What is the Pythagorean theorem?",
                                    "Graph y = sin(x)",
                                    "Convert 5 meters to feet"], id: \.self) { example in
                                Button(action: {
                                    viewModel.input = example
                                }) {
                                    Text("• \(example)")
                                        .foregroundColor(.blue)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                        .background(Color.blue.opacity(0.05))
                        .cornerRadius(8)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .sheet(isPresented: $isShowingSettings) {
            NavigationView {
                SettingsView()
                    .environmentObject(viewModel)
            }
        }
    }
}

struct AIProviderButton: View {
    let provider: AIProvider
    let isSelected: Bool
    let hasAPIKey: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    Image(systemName: provider.iconName)
                        .font(.system(size: 24))
                        .foregroundColor(hasAPIKey ? .primary : .gray)
                    
                    if !hasAPIKey && provider.requiresAPIKey {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.orange)
                            .offset(x: 10, y: -10)
                    }
                }
                .frame(width: 40, height: 40)
                .background(isSelected ? Color.blue.opacity(0.2) : Color.clear)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
                )
                
                Text(provider.rawValue)
                    .font(.caption2)
                    .foregroundColor(hasAPIKey ? .primary : .gray)
            }
            .frame(width: 70)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}