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
    public let symptoms: [STSymptom]
    public let ratings: [STRating]
    
    open override var textChoices: [ORKTextChoice] {
        return self.symptoms.map { self.textChoiceGenerator($0) }
    }
    
    open override var style: ORKChoiceAnswerStyle {
        return .multipleChoice
    }
    
    public init(
        symptoms: [STSymptom],
        ratings: [STRating],
        textChoiceGenerator: @escaping (STSymptom) -> RSTextChoiceWithAuxiliaryAnswer,
        supportsAddingSymptoms: Bool
        ) {
        self.symptoms = symptoms
        self.ratings = ratings
        self.textChoiceGenerator = textChoiceGenerator
        self.supportsAddingSymptoms = supportsAddingSymptoms
        super.init(style: .multipleChoice, textChoices: [])
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
