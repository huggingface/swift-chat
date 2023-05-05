//
//  State.swift
//  SwiftChat
//
//  Created by Pedro Cuenca on 3/5/23.
//

import Foundation

struct GenerationConfiguration {
    var prompt = ""
    var temperature = 0.2
    var maxNewTokens = 128
    var topP = 0.9
    var repetitionPenalty = 1.2
}


class Settings {
    static let shared = Settings()
    
    let defaults = UserDefaults.standard
    
    enum Keys: String {
        case model
    }
    
    private init() {
        defaults.register(defaults: [
            Keys.model.rawValue: "",
        ])
    }
    
    var currentModel: URL? {
        set {
            defaults.set(newValue?.path ?? "", forKey: Keys.model.rawValue)
        }
        get {
            let current = defaults.string(forKey: Keys.model.rawValue) ?? ""
            guard current != "" else { return nil }
            return URL(fileURLWithPath: current)
        }
    }
}
