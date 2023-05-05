//
//  TextGenerationModel.swift
//  SwiftChat
//
//  Created by Pedro Cuenca on 5/5/23.
//

import CoreML

class LanguageModel: ObservableObject {
    let model: MLModel
    let contextLength: Int    

    init(model: MLModel) {
        self.model = model
        
        // We assume inputs named "input_ids" with shape (1, seq_length)
        // Perhaps we should convert to vectors of shape (seq_length) and use sequenceConstraint instead of shapeConstraint
        let inputDescription = model.modelDescription.inputDescriptionsByName["input_ids"]
        let range = inputDescription?.multiArrayConstraint?.shapeConstraint.sizeRangeForDimension[1] as? NSRange
        self.contextLength = range?.length ?? 128
    }
}
