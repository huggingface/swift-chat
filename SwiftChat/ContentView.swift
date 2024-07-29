//
//  ContentView.swift
//  SwiftChat
//
//  Created by Pedro Cuenca on April 2023
//  Based on code by Cyril Zakka from https://github.com/cyrilzakka/pen
//

import SwiftUI
import Generation
import Models

enum ModelState: Equatable {
    case noModel
    case loading
    case ready(Double?)
    case generating(Double)
    case failed(String)
}

struct ContentView: View {
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    @State private var config = GenerationConfig(maxNewTokens: 20)
    @State private var prompt = "Write a poem about Valencia\n"
    @State private var modelURL: URL? = nil
    @State private var languageModel: LanguageModel? = nil
    
    @State private var isSettingsPresented = false
    @State private var isFirstLaunch = true
    
    @State private var status: ModelState = .noModel
    @State private var outputText: AttributedString = ""
    
    @Binding var clearTriggered: Bool
    
    func modelDidChange() {
        guard status != .loading else { return }
        
        status = .loading
        Task.init {
            do {
                languageModel = try await ModelLoader.load(url: modelURL)
                if let config = languageModel?.defaultGenerationConfig {
                    let maxNewTokens = self.config.maxNewTokens
                    self.config = config
                    Task.init {
                        // Refresh after slider limits have been updated
                        self.config.maxNewTokens = min(maxNewTokens, languageModel?.maxContextLength ?? 20)
                    }
                }
                status = .ready(nil)
                isSettingsPresented = false
            } catch {
                print("No model could be loaded: \(error)")
                status = .noModel
            }

        }
    }
    
    func clear() {
        outputText = ""
    }

    func run() {
        guard let languageModel = languageModel else { return }
        
        @Sendable func showOutput(currentGeneration: String, progress: Double, completedTokensPerSecond: Double? = nil) {
            Task { @MainActor in
                // Temporary hack to remove start token returned by llama tokenizers
                var response = currentGeneration.deletingPrefix("<s> ")
                
                // Strip prompt
                guard response.count > prompt.count else { return }
                response = response[prompt.endIndex...].replacingOccurrences(of: "\\n", with: "\n")
                
                // Format prompt + response with different colors
                var styledPrompt = AttributedString(prompt)
                styledPrompt.foregroundColor = .black
                
                var styledOutput = AttributedString(response)
                styledOutput.foregroundColor = .accentColor
                
                outputText = styledPrompt + styledOutput
                if let tps = completedTokensPerSecond {
                    status = .ready(tps)
                } else {
                    status = .generating(progress)
                }
            }
        }
        
        Task.init {
            status = .generating(0)
            var tokensReceived = 0
            let begin = Date()
            do {
                let output = try await languageModel.generate(config: config, prompt: prompt) { inProgressGeneration in
                    tokensReceived += 1
                    showOutput(currentGeneration: inProgressGeneration, progress: Double(tokensReceived)/Double(config.maxNewTokens))
                }
                let completionTime = Date().timeIntervalSince(begin)
                let tokensPerSecond = Double(tokensReceived) / completionTime
                showOutput(currentGeneration: output, progress: 1, completedTokensPerSecond: tokensPerSecond)
                print("Took \(completionTime)")
            } catch {
                print("Error \(error)")
                Task { @MainActor in
                    status = .failed("\(error)")
                }
            }
        }
    }
    
    @ViewBuilder
    var runButton: some View {
        switch status {
        case .noModel:
            EmptyView()
        case .loading:
            ProgressView().controlSize(.small).padding(.trailing, 6)
        case .ready, .failed:
            Button(action: run) { Label("Run", systemImage: "play.fill") }
                .keyboardShortcut("R")
        case .generating(let progress):
            ProgressView(value: progress).controlSize(.small).progressViewStyle(.circular).padding(.trailing, 6)
        }
    }

    var chatView: some View {
        GeometryReader { geometry in
            VStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your input (use format appropriate for the model you are using)")
                        .font(.caption)
                        .foregroundColor(.gray)

                    TextEditor(text: $prompt)
                        .font(.body)
                        .fontDesign(.rounded)
                        .scrollContentBackground(.hidden)
                        .multilineTextAlignment(.leading)
                        .padding(.all, 4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                }
                .frame(height: 100)
                .padding(.bottom, 16)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Language Model Output")
                        .font(.caption)
                        .foregroundColor(.gray)

                    Text(outputText)
                        .font(.system(size: 14))
                        .foregroundColor(.blue)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                        .frame(minWidth: geometry.size.width - 44, minHeight: 200, alignment: Alignment(horizontal: .leading, vertical: .top))
                        .padding(.all, 4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                        .onChange(of: clearTriggered) { _, _ in
                            clear()
                        }
                }
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    runButton
                }
            }
        }
        .navigationTitle("Language Model Tester")
    }
    
    var regularView: some View {
        NavigationSplitView {
            VStack {
                ControlView(prompt: prompt, config: $config, model: $languageModel, modelURL: $modelURL)
                StatusView(status: $status)
            }
            .navigationSplitViewColumnWidth(min: 250, ideal: 300)
        } detail: {
            chatView
        }
    }
    
#if os(iOS)
    var compactView: some View {
        NavigationView {
            VStack {
                chatView
                StatusView(status: $status)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Settings", systemImage: "gear") {
                        isSettingsPresented = true
                    }
                }
            }
        }
        .onAppear {
            if isFirstLaunch {
                isSettingsPresented = true
                isFirstLaunch = false
            }
        }
        .sheet(isPresented: $isSettingsPresented) {
            NavigationView {
                VStack {
                    ControlView(prompt: prompt, config: $config, model: $languageModel, modelURL: $modelURL)
                    StatusView(status: $status)
                }
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            isSettingsPresented = false
                        }
                    }
                }
            }
        }
    }
#endif
    
    var body: some View {
        Group {
#if os(iOS)
            if horizontalSizeClass == .compact && (verticalSizeClass == .compact || verticalSizeClass == .regular) {
                compactView
            } else {
                regularView
            }
#else
            regularView
#endif
        }
        .onAppear {
            modelDidChange()
        }
        .onChange(of: modelURL) {
            modelDidChange()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(clearTriggered: .constant(false))
    }
}

extension String {
    func deletingPrefix(_ prefix: String) -> String {
        guard hasPrefix(prefix) else { return self }
        return String(dropFirst(prefix.count))
    }
}
