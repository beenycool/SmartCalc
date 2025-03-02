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
    @State private var selectedMode: CalculatorMode = .basic
    @State private var showingSettings = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Mode selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(CalculatorMode.allCases, id: \.self) { mode in
                            ModeButton(
                                mode: mode,
                                isSelected: selectedMode == mode
                            ) {
                                withAnimation {
                                    selectedMode = mode
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .background(Color.secondary.opacity(0.05))
                
                // Main calculator view
                CalculatorView(mode: $selectedMode)
                    .environmentObject(calculatorViewModel)
            }
            .navigationTitle("SmartCalc")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gear")
                    }
                    .sheet(isPresented: $showingSettings) {
                        NavigationStack {
                            SettingsView()
                                .environmentObject(calculatorViewModel)
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        ForEach(CalculatorMode.allCases, id: \.self) { mode in
                            Button {
                                selectedMode = mode
                            } label: {
                                Label(mode.displayName, systemImage: mode.icon)
                            }
                        }
                    } label: {
                        Label("Modes", systemImage: "calculator")
                    }
                }
            }
        }
    }
}

struct ModeButton: View {
    let mode: CalculatorMode
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: mode.icon)
                    .font(.system(size: 24))
                    .frame(width: 40, height: 40)
                    .background(isSelected ? Color.blue.opacity(0.2) : Color.clear)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
                    )
                
                Text(mode.displayName)
                    .font(.caption)
                    .foregroundColor(isSelected ? .primary : .secondary)
            }
            .frame(width: 80)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
