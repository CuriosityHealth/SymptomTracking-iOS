//
//  STAddedSymptomsIntermediateResult.swift
//  SymptomTracking
//
//  Created by James Kizer on 10/22/18.
//

import UIKit

import UIKit
import ResearchSuiteResultsProcessor
import ResearchKit
import Gloss
import LS2SDK

open class STAddedSymptomsIntermediateResult: RSRPIntermediateResult, RSRPFrontEndTransformer {
    
    public static func supportsType(type: String) -> Bool {
        return type == "addedSymptoms"
    }
    
    public static func transform(taskIdentifier: String, taskRunUUID: UUID, parameters: [String : AnyObject]) -> RSRPIntermediateResult? {
        
        guard let stepResult = parameters["symptoms"] as? ORKStepResult,
            let symptomTrackingResult = stepResult.firstResult as? STSymptomTrackingResult,
            let addedSymptoms = symptomTrackingResult.addedSymptoms,
            addedSymptoms.count > 0 else {
                return nil
        }
        
        let result = STAddedSymptomsIntermediateResult(
            uuid: UUID(),
            taskIdentifier: taskIdentifier,
            taskRunUUID: taskRunUUID,
            addedSymptoms: addedSymptoms
        )
        
        result.startDate = symptomTrackingResult.startDate
        result.endDate = symptomTrackingResult.endDate
        
        return result
    }
    
    public let addedSymptoms: [STSymptom]
    
    public init(
        uuid: UUID,
        taskIdentifier: String,
        taskRunUUID: UUID,
        addedSymptoms: [STSymptom]
        ) {
        
        self.addedSymptoms = addedSymptoms
        
        super.init(
            type: "STAddedSymptomsIntermediateResult",
            uuid: uuid,
            taskIdentifier: taskIdentifier,
            taskRunUUID: taskRunUUID
        )
    }
    
}

extension STAddedSymptomsIntermediateResult {
    @objc open override func evaluate() -> AnyObject? {
        return self.addedSymptoms as AnyObject
    }
}
