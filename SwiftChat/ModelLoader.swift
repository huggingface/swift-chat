//
//  ModelLoader.swift
//  SwiftChat
//
//  Created by Pedro Cuenca on 5/5/23.
//

import CoreML
import Path

class ModelLoader {
    static let models = Path.applicationSupport / "hf-compiled-transformers"
    static let lastCompiledModel = models / "last-model.mlmodelc"
        
    static func load(url: URL?) async throws -> LanguageModel {
        if let url = url {
            print("Compiling model \(url)")
            let compiledURL = try await MLModel.compileModel(at: url)
            
            // Cache compiled
            let compiled = ModelLoader.lastCompiledModel
            try ModelLoader.models.mkdir(.p)
            try Path(url: compiledURL)?.move(to: compiled, overwrite: true)
        }
        
        // Load last model used (or just compiled)
        print("Loading model from \(lastCompiledModel.url)")
        let config = MLModelConfiguration()
        config.computeUnits = .all
        let model = try MLModel(contentsOf: lastCompiledModel.url, configuration: config)
        print("Done")
        return LanguageModel(model: model)
    }
}

extension String: Error {}
