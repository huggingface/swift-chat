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

struct ContentView: View {
    @State private var config = GenerationConfig(maxNewTokens: 20)
    @State private var prompt = "My name is Pedro and I am "
    @State private var modelURL: URL? = nil
    @State private var languageModel: LanguageModel? = nil
    
    enum ModelLoadingState {
        case noModel
        case loading
        case ready
    }
    @State private var status: ModelLoadingState = .noModel
    
    
    func modelDidChange() {
        guard status != .loading else { return }
        
        status = .loading
        Task.init {
            do {
                languageModel = try await ModelLoader.load(url: modelURL)
                config.bosTokenId = languageModel?.bosTokenId
                config.eosTokenId = languageModel?.eosTokenId
                status = .ready
            } catch {
                print("No model could be loaded: \(error)")
                status = .noModel
            }

        }
    }

    func run() {
        guard let languageModel = languageModel else { return }
        
        @Sendable func showOutput(currentGeneration: String) {
            Task { @MainActor in
                prompt = currentGeneration
            }
        }
        
        Task.init {
            let output = await languageModel.generate(config: config, prompt: prompt) { inProgressGeneration in
                showOutput(currentGeneration: inProgressGeneration)
            }
            showOutput(currentGeneration: output)
        }
    }
    
    @ViewBuilder
    var runButton: some View {
        switch status {
        case .noModel:
            EmptyView()
        case .loading:
            ProgressView().controlSize(.small).padding(.trailing, 6)
        case .ready:
            Button(action: run) { Label("Run", systemImage: "play.fill") }
                .keyboardShortcut("R")
        }
    }
    
    var body: some View {
        NavigationSplitView {
            ControlView(prompt: prompt, config: $config, model: $languageModel, modelURL: $modelURL)
                .navigationSplitViewColumnWidth(min: 250, ideal: 300)
        } detail: {
            TextEditor(text: $prompt)
                .font(.body)
                .fontDesign(.rounded)
                .scrollContentBackground(.hidden)
                .lineSpacing(10)
                .padding()
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        runButton
                    }
                }
        }.onAppear {
            modelDidChange()
        }
        .onChange(of: modelURL) { model in
            modelDidChange()
        }
//        .onChange(of: completer.status) { status in
//            switch status {
//            case .missingModel, .idle, .working, .starting:
//                print("Error")
//            case .progress, .done:
//                promptArea = completer.status.response!.result
//            case .failed(let error):
//                print("\(error)")
//            }
//        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
