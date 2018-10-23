//
//  STSymptomTrackingResult.swift
//  SymptomTracking
//
//  Created by James Kizer on 10/22/18.
//

import UIKit
import ResearchSuiteExtensions

open class STSymptomTrackingResult: RSEnhancedMultipleChoiceResult {
    
    open var event: STSymptomSeverityRatingEvent?
    open var addedSymptoms: [STSymptom]?
    
    override open func copy(with zone: NSZone? = nil) -> Any {
        let obj = super.copy(with: zone)
        if let result = obj as? STSymptomTrackingResult {
            result.event = self.event
            result.addedSymptoms = self.addedSymptoms
            return result
        }
        else {
            return obj
        }
    }
    
}
