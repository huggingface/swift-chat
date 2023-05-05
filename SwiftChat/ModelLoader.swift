//
//  ModelLoader.swift
//  SwiftChat
//
//  Created by Pedro Cuenca on 5/5/23.
//

import CoreML


class ModelLoader {
    let url: URL
    
    init(url: URL) {
        self.url = url
    }

    func load() async throws -> LanguageModel {
        print("Compiling model \(url)")
        let compiledURL = try await MLModel.compileModel(at: url)

        print("Loading model")
        let config = MLModelConfiguration()
        config.computeUnits = .all
        let model = try MLModel(contentsOf: compiledURL, configuration: config)
        print("Done")
        return LanguageModel(model: model)
    }
}
