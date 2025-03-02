import SwiftUI
import Charts

struct CalculatorView: View {
    private let subtleBlue = Color.blue.opacity(0.1)
    private let subtlePurple = Color.purple.opacity(0.1)
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
                    .font(.title2.bold())
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Button {
                    showingModeFeatures.toggle()
                } label: {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(.primary)
                        .font(.title3)
                }
                .sheet(isPresented: $showingModeFeatures) {
                    ModeFeaturesView(mode: mode)
                }
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 15)
                    .fill(
                        LinearGradient(
                            colors: [
                                subtleBlue,
                                subtlePurple
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .padding(.horizontal)
            .padding(.top)
            
            if mode == .ai {
                AIAssistantView()
            } else if mode == .finance {
                FinanceView()
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        // Input area
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                TextField(mode.placeholder, text: $viewModel.input)
                                    .textFieldStyle(.plain)
                                    .font(.system(size: 24, weight: .medium, design: .monospaced))
                                    .submitLabel(.done)
                                    .focused($isInputFocused)
                                    .padding()
                                    .background {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(.systemBackground))
                                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                                    }
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
                                            .foregroundStyle(.secondary)
                                            .font(.title2)
                                    }
                                }
                            }
                            
                            if !mode.supportedOperations.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(mode.supportedOperations, id: \.self) { operation in
                                            Button {
                                                insertOperation(operation)
                                            } label: {
                                                Text(operation)
                                                    .font(.headline)
                                                    .padding(.horizontal, 16)
                                                    .padding(.vertical, 8)
                                                    .background {
                                                        Capsule()
                                                            .fill(subtleBlue)
                                                    }
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                    .padding(.vertical, 8)
                                }
                            }
                        }
                        .padding()
                        
                        if !viewModel.result.isEmpty {
                            VStack(alignment: .trailing, spacing: 12) {
                                Text(viewModel.result)
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundStyle(.primary)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .padding()
                                    .background {
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(Color(.systemBackground))
                                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                                    }
                                
                                if !viewModel.steps.isEmpty {
                                    Button {
                                        withAnimation {
                                            viewModel.showSteps.toggle()
                                        }
                                    } label: {
                                        HStack {
                                            Text("Solution Steps")
                                                .font(.subheadline.bold())
                                            Image(systemName: viewModel.showSteps ? "chevron.up" : "chevron.down")
                                        }
                                        .foregroundStyle(.secondary)
                                    }
                                    
                                    if viewModel.showSteps {
                                        VStack(alignment: .leading, spacing: 8) {
                                            ForEach(viewModel.steps, id: \.self) { step in
                                                Text(step)
                                                    .font(.system(.body, design: .monospaced))
                                                    .foregroundStyle(.secondary)
                                            }
                                        }
                                        .transition(.move(edge: .top).combined(with: .opacity))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding()
                                        .background {
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color(.systemBackground))
                                                .shadow(color: .black.opacity(0.05), radius: 5)
                                        }
                                    }
                                }
                            }
                            .padding()
                        }
                        
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
                        
                        if !viewModel.savedVariables.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Stored Variables")
                                    .font(.title3.bold())
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(Array(viewModel.savedVariables.keys.sorted()), id: \.self) { name in
                                            if let value = viewModel.savedVariables[name] {
                                                Button {
                                                    viewModel.input += name
                                                } label: {
                                                    VStack(alignment: .leading, spacing: 4) {
                                                        Text(name)
                                                            .font(.headline)
                                                        Text(String(format: "%.6g", value))
                                                            .font(.caption)
                                                            .foregroundStyle(.secondary)
                                                    }
                                                    .padding(12)
                                                    .background {
                                                        RoundedRectangle(cornerRadius: 10)
                                                            .fill(Color.blue.opacity(0.1))
                                                    }
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
                
                HStack(spacing: 20) {
                    Button {
                        showingHistory.toggle()
                    } label: {
                        Image(systemName: "clock.fill")
                            .font(.title2)
                            .foregroundStyle(.primary)
                    }
                    .sheet(isPresented: $showingHistory) {
                        HistoryView()
                    }
                    
                    Spacer()
                    
                    switch mode {
                    case .matrix:
                        Button {
                            showingMatrixEditor.toggle()
                        } label: {
                            Image(systemName: "rectangle.grid.2x2.fill")
                                .font(.title2)
                                .foregroundStyle(.primary)
                        }
                    case .graph:
                        Button {
                            viewModel.calculate()
                        } label: {
                            Image(systemName: "chart.xyaxis.line")
                                .font(.title2)
                                .foregroundStyle(.primary)
                        }
                    default:
                        Button {
                            viewModel.clearAll()
                        } label: {
                            Image(systemName: "trash.fill")
                                .font(.title2)
                                .foregroundStyle(.primary)
                        }
                    }
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [
                                    subtleBlue,
                                    subtlePurple
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
                .padding()
            }
        }
        .onChange(of: mode) { newMode in
            viewModel.currentMode = newMode
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

struct ModeFeaturesView: View {
    let mode: CalculatorMode
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(mode.features) { feature in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(feature.name)
                                .font(.headline)
                            Text(feature.description)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 6)
                    }
                } header: {
                    Text("\(mode.displayName) Mode Features")
                        .textCase(nil)
                        .font(.title3.bold())
                        .foregroundStyle(.primary)
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
    @EnvironmentObject var viewModel: CalculatorViewModel
    let function: String
    @State private var scale: Double = 1.0
    @State private var offset: CGSize = .zero
    
    var body: some View {
        VStack(spacing: 16) {
            if !viewModel.graphData.isEmpty {
                Chart {
                    LineMark(
                        x: .value("x", viewModel.graphData.map { $0.x }),
                        y: .value("y", viewModel.graphData.map { $0.y })
                    )
                    .foregroundStyle(.blue)
                    .lineStyle(.init(lineWidth: 2))
                }
                .chartXAxis {
                    AxisMarks(position: .bottom) {
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel()
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) {
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel()
                    }
                }
                .chartXScale(domain: -10 * scale...10 * scale)
                .chartYScale(domain: -10 * scale...10 * scale)
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            scale = max(0.1, min(10, value))
                        }
                )
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            offset = gesture.translation
                        }
                        .onEnded { _ in
                            offset = .zero
                        }
                )
                .frame(maxWidth: .infinity)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.1), radius: 8)
                }
            } else {
                Text("Enter a function to graph")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
            
            HStack(spacing: 20) {
                Button {
                    scale = max(0.1, scale - 0.1)
                } label: {
                    Image(systemName: "minus.magnifyingglass")
                        .font(.title3)
                        .foregroundStyle(.primary)
                        .frame(width: 44, height: 44)
                        .background {
                            Circle()
                                .fill(subtleBlue)
                        }
                }
                
                Text("Zoom: \(String(format: "%.1f", scale))x")
                    .font(.headline)
                    .frame(width: 100)
                
                Button {
                    scale = min(10, scale + 0.1)
                } label: {
                    Image(systemName: "plus.magnifyingglass")
                        .font(.title3)
                        .foregroundStyle(.primary)
                        .frame(width: 44, height: 44)
                        .background {
                            Circle()
                                .fill(subtleBlue)
                        }
                }
            }
        }
    }
}

struct MatrixView: View {
    @EnvironmentObject var viewModel: CalculatorViewModel
    @Binding var showingEditor: Bool
    @State private var matrixSize = (rows: 2, cols: 2)
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Matrix A")
                    .font(.title3.bold())
                    .foregroundStyle(.primary)
                
                ForEach(0..<matrixSize.rows, id: \.self) { i in
                    HStack(spacing: 8) {
                        ForEach(0..<matrixSize.cols, id: \.self) { j in
                            let index = i * matrixSize.cols + j
                            if index < viewModel.matrixA.count {
                                TextField("0", value: .init(
                                    get: { viewModel.matrixA[i][j] },
                                    set: { viewModel.matrixA[i][j] = $0 }
                                ), format: .number)
                                .textFieldStyle(.plain)
                                .multilineTextAlignment(.center)
                                .frame(width: 60)
                                .padding(8)
                                .background {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(.systemBackground))
                                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                                }
                            }
                        }
                    }
                }
            }
            
            HStack(spacing: 12) {
                ForEach(["×", "+", "-", "det"], id: \.self) { op in
                    Button {
                        viewModel.input = op
                    } label: {
                        Text(op)
                            .font(.title3.bold())
                            .frame(width: 44, height: 44)
                            .background {
                                Circle()
                                    .fill(subtleBlue)
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
            
            if viewModel.input != "det" {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Matrix B")
                        .font(.title3.bold())
                        .foregroundStyle(.primary)
                    
                    ForEach(0..<matrixSize.rows, id: \.self) { i in
                        HStack(spacing: 8) {
                            ForEach(0..<matrixSize.cols, id: \.self) { j in
                                let index = i * matrixSize.cols + j
                                if index < viewModel.matrixB.count {
                                    TextField("0", value: .init(
                                        get: { viewModel.matrixB[i][j] },
                                        set: { viewModel.matrixB[i][j] = $0 }
                                    ), format: .number)
                                    .textFieldStyle(.plain)
                                    .multilineTextAlignment(.center)
                                    .frame(width: 60)
                                    .padding(8)
                                    .background {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color(.systemBackground))
                                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            HStack(spacing: 16) {
                VStack(spacing: 8) {
                    Text("Rows: \(matrixSize.rows)")
                        .font(.headline)
                    
                    HStack(spacing: 12) {
                        Button {
                            matrixSize.rows = max(1, matrixSize.rows - 1)
                            resizeMatrices()
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.blue)
                        }
                        
                        Button {
                            matrixSize.rows = min(5, matrixSize.rows + 1)
                            resizeMatrices()
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.blue)
                        }
                    }
                }
                
                VStack(spacing: 8) {
                    Text("Columns: \(matrixSize.cols)")
                        .font(.headline)
                    
                    HStack(spacing: 12) {
                        Button {
                            matrixSize.cols = max(1, matrixSize.cols - 1)
                            resizeMatrices()
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.blue)
                        }
                        
                        Button {
                            matrixSize.cols = min(5, matrixSize.cols + 1)
                            resizeMatrices()
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.blue)
                        }
                    }
                }
            }
            .padding(.top, 8)
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10)
        }
    }
    
    private func resizeMatrices() {
        viewModel.matrixA = Array(repeating: Array(repeating: 0.0, count: matrixSize.cols),
                                count: matrixSize.rows)
        viewModel.matrixB = Array(repeating: Array(repeating: 0.0, count: matrixSize.cols),
                                count: matrixSize.rows)
    }
}

struct StatisticsView: View {
    let data: [Double]
    @State private var chartType: ChartType = .bar
    
    enum ChartType {
        case bar, histogram, line
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Picker("Chart Type", selection: $chartType) {
                Text("Bar").tag(ChartType.bar)
                Text("Histogram").tag(ChartType.histogram)
                Text("Line").tag(ChartType.line)
            }
            .pickerStyle(.segmented)
            
            if !data.isEmpty {
                Chart {
                    switch chartType {
                    case .bar:
                        ForEach(Array(data.enumerated()), id: \.offset) { index, value in
                            BarMark(
                                x: .value("Index", index),
                                y: .value("Value", value)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                        }
                    case .histogram:
                        let bins = createHistogramBins(data)
                        ForEach(bins, id: \.range.lowerBound) { bin in
                            BarMark(
                                x: .value("Range", bin.range.lowerBound),
                                y: .value("Count", bin.count)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                        }
                    case .line:
                        LineMark(
                            x: .value("Index", Array(0..<data.count)),
                            y: .value("Value", data)
                        )
                        .foregroundStyle(.blue)
                        .lineStyle(.init(lineWidth: 3))
                    }
                }
                .chartXAxis {
                    AxisMarks(position: .bottom)
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 200)
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.1), radius: 8)
                }
            } else {
                Text("Enter comma-separated numbers")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
    }
    
    private struct HistogramBin {
        let range: ClosedRange<Double>
        let count: Int
    }
    
    private func createHistogramBins(_ data: [Double]) -> [HistogramBin] {
        guard !data.isEmpty else { return [] }
        
        let min = data.min() ?? 0
        let max = data.max() ?? 0
        let binCount = 10
        let binWidth = (max - min) / Double(binCount)
        
        var bins = [HistogramBin]()
        
        for i in 0..<binCount {
            let lowerBound = min + Double(i) * binWidth
            let upperBound = lowerBound + binWidth
            let count = data.filter { $0 >= lowerBound && $0 < upperBound }.count
            bins.append(HistogramBin(range: lowerBound...upperBound, count: count))
        }
        
        return bins
    }
}

struct ProgrammerView: View {
    let value: String
    @State private var selectedBase: NumberBase = .decimal
    
    enum NumberBase {
        case binary, octal, decimal, hexadecimal
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Picker("Base", selection: $selectedBase) {
                Text("BIN").tag(NumberBase.binary)
                Text("OCT").tag(NumberBase.octal)
                Text("DEC").tag(NumberBase.decimal)
                Text("HEX").tag(NumberBase.hexadecimal)
            }
            .pickerStyle(.segmented)
            
            if let number = Int(value) {
                VStack(spacing: 16) {
                    ForEach([
                        ("BIN", String(number, radix: 2)),
                        ("OCT", String(number, radix: 8)),
                        ("DEC", String(number)),
                        ("HEX", String(number, radix: 16).uppercased())
                    ], id: \.0) { base, value in
                        HStack {
                            Text("\(base):")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                                .frame(width: 60, alignment: .trailing)
                            
                            Text(value)
                                .font(.system(.title3, design: .monospaced))
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(.systemBackground))
                                        .shadow(color: .black.opacity(0.05), radius: 4)
                                }
                        }
                    }
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(["AND", "OR", "XOR", "NOT", "<<", ">>"], id: \.self) { op in
                        Button {
                            // Operation handling would go here
                        } label: {
                            Text(op)
                                .font(.headline)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background {
                                    Capsule()
                                        .fill(subtleBlue)
                                }
                       }
                       .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 8)
            }
        }
        .padding()
    }
}

struct HistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel: CalculatorViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.history) { entry in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(entry.input)
                                .font(.headline)
                            Text(entry.result)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                        }
                    }
                }
                .padding()
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
