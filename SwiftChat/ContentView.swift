//
//  ContentView.swift
//  SwiftChat
//
//  Created by Cyril Zakka on 4/3/23.
//

import SwiftUI


struct ContentView: View {
    @Environment(\.openURL) var openURL
    
    @State private var config = GenerationConfiguration()
    @State private var prompt = "Write a recipe for chocolate chip cookies"
    @State private var model: URL? = nil
    @State private var languageModel = LanguageModel()
    
    func run() {
        config.prompt = prompt
//        completer.complete(config, openURL: openURL)
    }
    
//    @ViewBuilder
//    var completeButton: some View {
//        switch completer.status {
//        case .starting(let progress):
//            ProgressView(value: progress)
//                .progressViewStyle(.circular)
//                .controlSize(.small)
//                .padding(.trailing, 6)
//        case .working:
//            ProgressView()
//                .controlSize(.small)
//                .padding(.trailing, 3)
//        default:
//            Button(action: run) { Label("Run", systemImage: "play.fill") }
//                .keyboardShortcut("R")
//                .disabled(completer.status == .missingModel)
//        }
//    }
    
    var body: some View {
        NavigationSplitView {
            ControlView(prompt: prompt, config: $config, model: $model, contextLength: languageModel.contextLength)
                .navigationSplitViewColumnWidth(min: 250, ideal: 300)
        } detail: {
            TextEditor(text: $prompt)
                .font(.body)
                .fontDesign(.rounded)
                .scrollContentBackground(.hidden)
                .lineSpacing(10)
                .padding()
                .toolbar {
//                    ToolbarItem(placement: .primaryAction) {
//                        completeButton
//                    }
                }
        }.onAppear {
            if let model {
//                completer.loadModel(at: model)
            }
        }
        .onChange(of: model) { model in
            if let model {
//                completer.loadModel(at: model)
            }
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
