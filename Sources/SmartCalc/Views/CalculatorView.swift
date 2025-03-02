import SwiftUI
import Charts

struct CalculatorView: View {
    @EnvironmentObject var viewModel: CalculatorViewModel
    @Binding var mode: CalculatorMode
    @FocusState private var isInputFocused: Bool
    @State private var showingModeFeatures = false
    @State private var showingHistory = false
    @State private var selectedFunction: String?
    @State private var showingMatrixEditor = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Mode header with features button
            HStack {
                Label(mode.displayName, systemImage: mode.icon)
                    .font(.headline)
                
                Spacer()
                
                Button {
                    showingModeFeatures.toggle()
                } label: {
                    Image(systemName: "info.circle")
                }
                .sheet(isPresented: $showingModeFeatures) {
                    ModeFeaturesView(mode: mode)
                }
            }
            .padding()
            .background(Color.secondary.opacity(0.1))
            
            ScrollView {
                VStack(spacing: 16) {
                    // Input area
                    VStack(alignment: .leading, spacing: 8) {
                        // Input field with mode-specific actions
                        HStack {
                            TextField(mode.placeholder, text: $viewModel.input)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.system(size: 20, weight: .regular, design: .monospaced))
                                .submitLabel(.done)
                                .focused($isInputFocused)
                                .onChange(of: viewModel.input) { _ in
                                    if viewModel.input.hasSuffix("=") {
                                        viewModel.calculate()
                                    }
                                }
                            
                            if !viewModel.input.isEmpty {
                                Button {
                                    viewModel.clearInput()
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        
                        // Quick access buttons for mode-specific operations
                        if !mode.supportedOperations.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(mode.supportedOperations, id: \.self) { operation in
                                        Button(operation) {
                                            insertOperation(operation)
                                        }
                                        .buttonStyle(.bordered)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    
                    // Result display
                    if !viewModel.result.isEmpty {
                        VStack(alignment: .trailing, spacing: 8) {
                            Text(viewModel.result)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .padding(.horizontal)
                            
                            if !viewModel.steps.isEmpty {
                                Button {
                                    withAnimation {
                                        viewModel.showSteps.toggle()
                                    }
                                } label: {
                                    HStack {
                                        Text("Solution Steps")
                                            .font(.subheadline)
                                        Image(systemName: viewModel.showSteps ? "chevron.up" : "chevron.down")
                                    }
                                    .foregroundColor(.secondary)
                                }
                                
                                if viewModel.showSteps {
                                    VStack(alignment: .leading, spacing: 4) {
                                        ForEach(viewModel.steps, id: \.self) { step in
                                            Text(step)
                                                .font(.system(.body, design: .monospaced))
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .transition(.move(edge: .top).combined(with: .opacity))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                        .padding()
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    
                    // Mode-specific views
                    switch mode {
                    case .graph:
                        GraphingView(function: viewModel.input)
                            .frame(height: 300)
                            .padding()
                    case .matrix:
                        MatrixView(showingEditor: $showingMatrixEditor)
                            .frame(height: 300)
                            .padding()
                    case .statistics:
                        StatisticsView(data: viewModel.getStatisticalData())
                            .frame(height: 300)
                            .padding()
                    case .programmer:
                        ProgrammerView(value: viewModel.input)
                            .frame(height: 200)
                            .padding()
                    default:
                        EmptyView()
                    }
                    
                    // Variable memory
                    if !viewModel.savedVariables.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Stored Variables")
                                .font(.headline)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(Array(viewModel.savedVariables.keys.sorted()), id: \.self) { name in
                                        if let value = viewModel.savedVariables[name] {
                                            Button {
                                                viewModel.input += name
                                            } label: {
                                                VStack(alignment: .leading) {
                                                    Text(name)
                                                        .font(.headline)
                                                    Text(String(format: "%.6g", value))
                                                        .font(.caption)
                                                        .foregroundColor(.secondary)
                                                }
                                                .padding(8)
                                                .background(Color.secondary.opacity(0.1))
                                                .cornerRadius(8)
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            
            // Bottom toolbar
            HStack {
                Button {
                    showingHistory.toggle()
                } label: {
                    Image(systemName: "clock")
                }
                .sheet(isPresented: $showingHistory) {
                    HistoryView()
                }
                
                Spacer()
                
                // Mode-specific actions
                switch mode {
                case .matrix:
                    Button {
                        showingMatrixEditor.toggle()
                    } label: {
                        Image(systemName: "rectangle.grid.2x2")
                    }
                case .graph:
                    Button {
                        viewModel.plotGraph()
                    } label: {
                        Image(systemName: "chart.xyaxis.line")
                    }
                default:
                    Button {
                        viewModel.clearAll()
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }
            .padding()
            .background(Color.secondary.opacity(0.1))
        }
        .onChange(of: mode) { _ in
            viewModel.currentMode = mode
            viewModel.clearInput()
        }
    }
    
    private func insertOperation(_ operation: String) {
        switch operation {
        case "π":
            viewModel.input += "3.14159"
        case "e":
            viewModel.input += "2.71828"
        default:
            if operation.count == 1 {
                viewModel.input += operation
            } else {
                viewModel.input += operation + "("
            }
        }
        isInputFocused = true
    }
}

// Helper Views
struct ModeFeaturesView: View {
    let mode: CalculatorMode
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(mode.features) { feature in
                        VStack(alignment: .leading) {
                            Text(feature.name)
                                .font(.headline)
                            Text(feature.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                } header: {
                    Text("\(mode.displayName) Mode Features")
                }
            }
            .navigationTitle("Features")
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
}

struct GraphingView: View {
    let function: String
    
    var body: some View {
        Chart {
            // Implementation depends on parsing the function
            // and generating points for the graph
        }
        .chartXAxis {
            AxisMarks(position: .bottom)
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
    }
}

struct MatrixView: View {
    @Binding var showingEditor: Bool
    
    var body: some View {
        VStack {
            // Matrix visualization and editing interface
            Text("Matrix Operations")
                .font(.headline)
        }
    }
}

struct StatisticsView: View {
    let data: [Double]
    
    var body: some View {
        VStack {
            // Statistical visualization and analysis
            Chart {
                // Implementation of statistical charts
            }
        }
    }
}

struct ProgrammerView: View {
    let value: String
    
    var body: some View {
        VStack {
            // Binary, hex, decimal representations
            // Bit manipulation interface
        }
    }
}

struct HistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel: CalculatorViewModel
    
    var body: some View {
        NavigationView {
            List(viewModel.history) { entry in
                VStack(alignment: .leading) {
                    Text(entry.input)
                        .font(.headline)
                    Text(entry.result)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("History")
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
}