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
