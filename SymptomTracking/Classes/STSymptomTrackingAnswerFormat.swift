//
//  STSymptomTrackingAnswerFormat.swift
//  SymptomTracking
//
//  Created by James Kizer on 10/21/18.
//

import UIKit
import ResearchKit
import ResearchSuiteExtensions

open class STSymptomTrackingAnswerFormat: ORKTextChoiceAnswerFormat {
    
    public let supportsAddingSymptoms: Bool
    public let textChoiceGenerator: (STSymptom) -> RSTextChoiceWithAuxiliaryAnswer
    
    public init(
        choices: [RSTextChoiceWithAuxiliaryAnswer],
        textChoiceGenerator: @escaping (STSymptom) -> RSTextChoiceWithAuxiliaryAnswer,
        supportsAddingSymptoms: Bool
        ) {
        self.supportsAddingSymptoms = supportsAddingSymptoms
        self.textChoiceGenerator = textChoiceGenerator
        super.init(style: .multipleChoice, textChoices: choices)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
