//
//  STSymptomTrackingStepGenerator.swift
//  SymptomTracking
//
//  Created by James Kizer on 10/21/18.
//

import UIKit
import ResearchKit
import ResearchSuiteTaskBuilder
import Gloss
import ResearchSuiteExtensions

open class STSymptomTrackingStepGenerator: RSTBBaseStepGenerator {

    open var supportedTypes: [String]! {
        return ["symptomTracking"]
    }
    
    public init() {}
    
    open func generateAuxiliaryItem(
        ratingOptions: [STRating],
        ratingPrompt: String?,
        helper: RSTBTaskBuilderHelper
    ) -> ORKFormItem? {
        
        let ratingOptionChoices: [ORKTextChoice] = ratingOptions.map { ratingOption in
            return ORKTextChoice(
                text: helper.localizationHelper.localizedString(ratingOption.prompt),
                detailText: nil,
                value: NSNumber(value: ratingOption.value),
                exclusive: false
            )
        }
        
        guard let firstRatingPrompt = ratingOptions.first?.prompt,
            let lastRatingPrompt = ratingOptions.last?.prompt else {
                return nil
        }
        
        let maximumValueDescription: String? = helper.localizationHelper.localizedString(lastRatingPrompt)
        let minimumValueDescription: String? = helper.localizationHelper.localizedString(firstRatingPrompt)
        
        let answerFormat = RSEnhancedTextScaleAnswerFormat(
            textChoices: ratingOptionChoices,
            defaultIndex: -1,
            vertical: false,
            maxValueLabel: nil,
            minValueLabel: nil,
            maximumValueDescription: maximumValueDescription,
            neutralValueDescription: nil,
            minimumValueDescription: minimumValueDescription,
            valueLabelHeight: nil
        )
        
        let formItem = ORKFormItem(identifier: "rating", text: ratingPrompt, answerFormat: answerFormat)
        formItem.isOptional = false
        return formItem
        
    }
    
    open func getTextChoiceGenerator(
        ratingOptions: [STRating],
        ratingPrompt: String?,
        supportsAddingSymptoms: Bool,
        helper: RSTBTaskBuilderHelper
        ) -> (STSymptom) -> RSTextChoiceWithAuxiliaryAnswer {
        
        let auxiliaryItem: ORKFormItem? = self.generateAuxiliaryItem(
            ratingOptions: ratingOptions,
            ratingPrompt: ratingPrompt,
            helper: helper
        )
        
        let textChoiceGenerator: (STSymptom) -> RSTextChoiceWithAuxiliaryAnswer = { symptom in
            return RSTextChoiceWithAuxiliaryAnswer(
                identifier: helper.localizationHelper.localizedString(symptom.identifier),
                text: helper.localizationHelper.localizedString(symptom.prompt),
                detailText: nil,
                value: symptom.identifier as NSString,
                exclusive: false,
                auxiliaryItem: auxiliaryItem
            )
        }
        
        return textChoiceGenerator
    }
    
//    open func generateChoices(
//        symptoms: [STSymptom],
//        ratingOptions: [STRating],
//        ratingPrompt: String?,
//        supportsAddingSymptoms: Bool,
//        helper: RSTBTaskBuilderHelper
//        ) -> [RSTextChoiceWithAuxiliaryAnswer] {
//
//
//        let auxiliaryItem: ORKFormItem? = self.generateAuxiliaryItem(
//            ratingOptions: ratingOptions,
//            ratingPrompt: ratingPrompt,
//            helper: helper
//        )
//
//        let textChoiceGenerator: (STSymptom) -> RSTextChoiceWithAuxiliaryAnswer = { symptom in
//            return RSTextChoiceWithAuxiliaryAnswer(
//                identifier: helper.localizationHelper.localizedString(symptom.identifier),
//                text: helper.localizationHelper.localizedString(symptom.prompt),
//                detailText: nil,
//                value: symptom.identifier as NSString,
//                exclusive: false,
//                auxiliaryItem: auxiliaryItem
//            )
//        }
//
//        let symptomChoices: [RSTextChoiceWithAuxiliaryAnswer] = symptoms.map { textChoiceGenerator($0) }
//
//        //TODO: Add support for adding symptoms
//        if supportsAddingSymptoms {
//            return symptomChoices
//        }
//        else {
//            return symptomChoices
//        }
//
//    }
    
    open func generateAnswerFormat(type: String, jsonObject: JSON, helper: RSTBTaskBuilderHelper) -> STSymptomTrackingAnswerFormat? {
        guard let stepDescriptor = STSymptomTrackingStepDescriptor(json: jsonObject) else {
            return nil
        }
        
        let getSymptomsForKey: (String?, Bool) -> [STSymptom] = { keyOpt, userDefined in
            if let key = keyOpt,
                let symptomsArray = helper.stateHelper?.objectInState(forKey: key) as? [Any] {
                
                if let symptoms = symptomsArray as? [STSymptom] {
                    return symptoms
                }
                else if let symptomsJSON = symptomsArray as? [JSON] {
                    return symptomsJSON.compactMap { symptomJSON in
                        if let symptom = STSymptom(json: symptomJSON) {
                            return STSymptom(
                                identifier: symptom.identifier,
                                prompt: helper.localizationHelper.localizedString(symptom.prompt),
                                text: helper.localizationHelper.localizedString(symptom.text),
                                userDefined: symptom.userDefined
                            )
                        }
                        else {
                            return nil
                        }
                    }
                }
                else {
                    return []
                }
            }
            else {
                return []
            }
        }
        
        let applicationDefinedSymptoms: [STSymptom] = getSymptomsForKey(stepDescriptor.applicationDefinedSymptomsKey, false)
        let userDefinedSymptoms: [STSymptom] = getSymptomsForKey(stepDescriptor.userDefinedSymptomsKey, true)
        let symptoms = applicationDefinedSymptoms + userDefinedSymptoms
        
        guard let ratingOptionsArray = helper.stateHelper?.objectInState(forKey: stepDescriptor.ratingOptionsKey) as? [Any] else {
            return nil
        }
        
        let ratingOptions: [STRating] = {
            
            if let ratingOptions = ratingOptionsArray as? [STRating] {
                return ratingOptions
            }
            else if let ratingOptionsJSON = ratingOptionsArray as? [JSON] {
                return ratingOptionsJSON.compactMap { ratingJSON in
                    if let rating = STRating(json: ratingJSON) {
                        return STRating(
                            identifier: rating.identifier,
                            prompt: helper.localizationHelper.localizedString(rating.prompt),
                            value: rating.value
                        )
                    }
                    else {
                        return nil
                    }
                }
            }
            else {
                return []
            }
            
        }()
        
        guard ratingOptions.count > 0,
            (symptoms.count > 0 || stepDescriptor.supportsAddingSymptoms) else {
                return nil
        }
        
        let textChoiceGenerator = self.getTextChoiceGenerator(
            ratingOptions: ratingOptions,
            ratingPrompt: stepDescriptor.ratingPrompt,
            supportsAddingSymptoms: stepDescriptor.supportsAddingSymptoms,
            helper: helper
        )
        
//        let choices = self.generateChoices(
//            symptoms: symptoms,
//            ratingOptions: ratingOptions,
//            ratingPrompt: stepDescriptor.ratingPrompt,
//            supportsAddingSymptoms: stepDescriptor.supportsAddingSymptoms,
//            helper: helper
//        )
        
//        let choices = symptoms.map { textChoiceGenerator($0) }
//
//        guard choices.count > 0 else {
//            return nil
//        }
        
        return STSymptomTrackingAnswerFormat(
            symptoms: symptoms,
            ratings: ratingOptions,
            textChoiceGenerator: textChoiceGenerator,
            supportsAddingSymptoms: stepDescriptor.supportsAddingSymptoms
        )
        
    }
    
    var cellControllerGenerators = [
        RSEnhancedMultipleChoiceCellWithTextScaleAccessoryController.self
    ]
    
    open func generateStep(type: String, jsonObject: JSON, helper: RSTBTaskBuilderHelper) -> ORKStep? {
        guard let answerFormat = self.generateAnswerFormat(type: type, jsonObject: jsonObject, helper: helper),
            let stepDescriptor = STSymptomTrackingStepDescriptor(json: jsonObject) else {
                return nil
        }
        
        let step = STSymptomTrackingStep(
            identifier: stepDescriptor.identifier,
            title: helper.localizationHelper.localizedString(stepDescriptor.title),
            text: helper.localizationHelper.localizedString(stepDescriptor.text),
            answer: answerFormat,
            cellControllerGenerators: self.cellControllerGenerators)
        
        if let formattedTitle = stepDescriptor.formattedTitle {
            step.attributedTitle = self.generateAttributedString(descriptor: formattedTitle, helper: helper)
        }
        
        if let formattedText = stepDescriptor.formattedText {
            step.attributedText = self.generateAttributedString(descriptor: formattedText, helper: helper)
        }
        
        step.isOptional = stepDescriptor.optional
        
//        if let allowsEmptySelection = stepDescriptor.allowsEmptySelection {
//            step.allowsEmptySelection = allowsEmptySelection.allowed
//            step.emptySelectionConfirmationAlert = allowsEmptySelection.confirmationAlert
//        }
        
        return step
    }
    
    open func processStepResult(type: String, jsonObject: JsonObject, result: ORKStepResult, helper: RSTBTaskBuilderHelper) -> JSON? {
        return nil
    }

}
