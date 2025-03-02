import SwiftUI

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Form {
            Section(header: Text("Appearance")) {
                Toggle("Dark Mode", isOn: $isDarkMode)
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
    }
}