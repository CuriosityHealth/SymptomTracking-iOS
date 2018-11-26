//
//  STSymptomTrackingEventWithNotesIntermediateResult.swift
//  SymptomTracking
//
//  Created by James Kizer on 11/24/18.
//

import UIKit
import ResearchSuiteResultsProcessor
import ResearchKit
import Gloss

open class STSymptomTrackingEventWithNotesIntermediateResult: RSRPIntermediateResult, RSRPFrontEndTransformer {

    public static func supportsType(type: String) -> Bool {
        return type == "symptomTrackingEventWithNotes"
    }
    
    public class func symptomSeverityRatingEvent(parameters: [String : AnyObject]) -> STSymptomSeverityRatingEvent? {
        guard let stepResult = parameters["symptoms"] as? ORKStepResult,
            let symptomTrackingResult = stepResult.firstResult as? STSymptomTrackingResult,
            let event = symptomTrackingResult.event else {
                return nil
        }
        
        return event
    }
    
    public class func notes(parameters: [String : AnyObject]) -> [String: String]? {
        guard let stepResults = parameters["notes"] as? [ORKStepResult] else {
                return nil
        }
        
        let pairs: [(String, String)] = stepResults.compactMap { (stepResult) -> (String, String)? in

            guard let result = stepResult.results?.first as? ORKTextQuestionResult,
                let textAnswer = result.textAnswer else {
                    return nil
            }
            
            //get identifier
            let identifierComponentArray = result.identifier.components(separatedBy: ".")
            assert(identifierComponentArray.count > 0)
            
            guard let identifier: String = identifierComponentArray.last else {
                return nil
            }

            return (identifier, textAnswer)
        }
        
        let resultMap: [String: String] = Dictionary(uniqueKeysWithValues: pairs)
        
        return resultMap
    }
    
    public static func transform(taskIdentifier: String, taskRunUUID: UUID, parameters: [String : AnyObject]) -> RSRPIntermediateResult? {
        
        guard let event = self.symptomSeverityRatingEvent(parameters: parameters),
            let notes = self.notes(parameters: parameters) else {
                return nil
        }
        
        let result = STSymptomTrackingEventWithNotesIntermediateResult(
            uuid: UUID(),
            taskIdentifier: taskIdentifier,
            taskRunUUID: taskRunUUID,
            event: event,
            notes: notes
        )
        
        result.startDate = RSRPDefaultResultHelpers.startDate(parameters: parameters)
        result.endDate = RSRPDefaultResultHelpers.endDate(parameters: parameters)
        
        return result
    }
    
    public let event: STSymptomSeverityRatingEvent
    public let notes: [String: String]
    
    public init(
        uuid: UUID,
        taskIdentifier: String,
        taskRunUUID: UUID,
        event: STSymptomSeverityRatingEvent,
        notes: [String: String]
        ) {
        
        self.event = event
        self.notes = notes
        
        super.init(
            type: "STSymptomTrackingEventResult",
            uuid: uuid,
            taskIdentifier: taskIdentifier,
            taskRunUUID: taskRunUUID
        )
    }
    
}
