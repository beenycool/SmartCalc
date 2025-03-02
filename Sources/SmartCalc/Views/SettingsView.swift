import SwiftUI

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var viewModel: CalculatorViewModel
    @State private var showAPIKeyAlert = false
    @State private var tempAPIKey = ""
    @State private var tempCustomEndpoint = ""
    
    var body: some View {
        Form {
            Section(header: Text("Appearance")) {
                Toggle("Dark Mode", isOn: $isDarkMode)
            }
            
            Section(header: Text("AI Assistant")) {
                Picker("AI Provider", selection: $viewModel.aiSettings.selectedProvider) {
                    ForEach(AIProvider.allCases) { provider in
                        Text(provider.rawValue).tag(provider)
                    }
                }
                .onChange(of: viewModel.aiSettings.selectedProvider) { provider in
                    viewModel.aiSettings.selectedModel = provider.defaultModel
                    
                    // Show API key prompt if needed
                    if provider.requiresAPIKey && viewModel.aiSettings.apiKey.isEmpty {
                        showAPIKeyAlert = true
                    }
                }
                
                Picker("Model", selection: $viewModel.aiSettings.selectedModel) {
                    ForEach(viewModel.aiSettings.selectedProvider.models) { model in
                        Text(model.name).tag(model)
                    }
                }
                
                if viewModel.aiSettings.selectedProvider.requiresAPIKey {
                    Button(viewModel.aiSettings.apiKey.isEmpty ? "Set API Key" : "Change API Key") {
                        tempAPIKey = viewModel.aiSettings.apiKey
                        showAPIKeyAlert = true
                    }
                }
                
                if viewModel.aiSettings.selectedProvider == .custom {
                    TextField("Custom Endpoint URL", text: $viewModel.aiSettings.customEndpoint)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                
                Toggle("Show Step-by-Step Solutions", isOn: $viewModel.aiSettings.showStepByStep)
                Toggle("Include Explanations", isOn: $viewModel.aiSettings.includeExplanations)
                Toggle("Generate Practice Problems", isOn: $viewModel.aiSettings.generatePracticeProblems)
                
                HStack {
                    Text("Temperature")
                    Spacer()
                    Text(String(format: "%.1f", viewModel.aiSettings.temperatureValue))
                }
                
                Slider(value: $viewModel.aiSettings.temperatureValue, in: 0...1, step: 0.1) {
                    Text("Temperature")
                } minimumValueLabel: {
                    Text("0")
                } maximumValueLabel: {
                    Text("1")
                }
            }
            
            Section(header: Text("About")) {
                LabeledContent("Version", value: "1.0.0")
                
                NavigationLink {
                    List {
                        Section(header: Text("Basic Mode")) {
                            Text("• Basic arithmetic: +, -, *, /")
                            Text("• Percentage calculation: 20% of 50")
                            Text("• Variable storage: tax = 0.08")
                        }
                        
                        Section(header: Text("Scientific Mode")) {
                            Text("• Trigonometry: sin, cos, tan")
                            Text("• Functions: sqrt, log, ln")
                            Text("• Power: 2^3")
                        }
                        
                        Section(header: Text("Converter Mode")) {
                            Text("• Length: m, ft, in, cm, km, mi")
                            Text("• Weight: kg, lb, g, oz, t")
                            Text("Format: '5.2 ft to m'")
                        }
                        
                        Section(header: Text("AI Assistant")) {
                            Text("• Natural language math problem solving")
                            Text("• Step-by-step solution breakdowns")
                            Text("• Mathematical concept explanations")
                            Text("• Practice problem generation")
                        }
                        
                        Section(header: Text("Finance Tools")) {
                            Text("• Mortgage and loan calculators")
                            Text("• Investment and compound interest")
                            Text("• Tip calculator with bill splitting")
                            Text("• Discount calculator and more")
                        }
                        
                        Section(header: Text("Tips")) {
                            Text("• Press Return/Enter to calculate")
                            Text("• Variables persist across calculations")
                            Text("• Tap solution steps to expand/collapse")
                        }
                    }
                    .navigationTitle("Help")
                } label: {
                    Text("Help")
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
        .alert("API Key", isPresented: $showAPIKeyAlert) {
            SecureField("Enter API Key", text: $tempAPIKey)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            Button("Cancel", role: .cancel) {}
            Button("Save") {
                viewModel.aiSettings.apiKey = tempAPIKey
            }
        } message: {
            Text("Please enter your \(viewModel.aiSettings.selectedProvider.rawValue) API key")
        }
    }
}