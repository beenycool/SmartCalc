import SwiftUI

@main
struct SmartCalcApp: App {
    @StateObject private var calculatorViewModel = CalculatorViewModel()
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(calculatorViewModel)
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var calculatorViewModel: CalculatorViewModel
    @State private var selectedTab: CalculatorMode = .basic
    
    var body: some View {
        VStack(spacing: 0) {
            // Mode selector
            Picker("Calculator Mode", selection: $selectedTab) {
                ForEach(CalculatorMode.allCases, id: \.self) { mode in
                    Text(mode.displayName).tag(mode)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            // Main calculator view
            CalculatorView(mode: $selectedTab)
                .environmentObject(calculatorViewModel)
            
            // Settings button
            HStack {
                Spacer()
                NavigationLink(destination: SettingsView()) {
                    Image(systemName: "gear")
                        .font(.title2)
                        .padding()
                }
            }
        }
        .navigationTitle("SmartCalc")
    }
}
