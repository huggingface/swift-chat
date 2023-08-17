//
//  ModelLoader.swift
//  SwiftChat
//
//  Created by Pedro Cuenca on 5/5/23.
//

import CoreML
import Path
import Models

class ModelLoader {
    static let models = Path.applicationSupport / "hf-compiled-transformers"
    static let lastCompiledModel = models / "last-model.mlmodelc"
        
    static func load(url: URL?) async throws -> LanguageModel {
        if let url = url {
            print("Compiling model \(url)")
            let compiledURL = try await MLModel.compileModel(at: url)
            
            // Cache compiled (keep last one only)
            try models.delete()
            let compiledPath = models / url.deletingPathExtension().appendingPathExtension("mlmodelc").lastPathComponent
            try ModelLoader.models.mkdir(.p)
            try Path(url: compiledURL)?.move(to: compiledPath, overwrite: true)
            
            // Create symlink (alternative: store name in UserDefaults)
            try compiledPath.symlink(as: lastCompiledModel)
        }
        
        // Load last model used (or the one we just compiled)
        let lastURL = try lastCompiledModel.readlink().url
        return try LanguageModel.loadCompiled(url: lastURL, computeUnits: .cpuAndGPU)
    }
}

import Combine

extension LanguageModel: ObservableObject {}
