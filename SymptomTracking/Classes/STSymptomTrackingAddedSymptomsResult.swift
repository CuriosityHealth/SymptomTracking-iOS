//
//  STSymptomTrackingAddedSymptomsResult.swift
//  SymptomTracking
//
//  Created by James Kizer on 10/22/18.
//

import UIKit
import ResearchKit

open class STSymptomTrackingAddedSymptomsResult: ORKResult {
    
    open var addedSymptoms: [STSymptom]?
    
    override open func copy(with zone: NSZone? = nil) -> Any {
        let obj = super.copy(with: zone)
        if let result = obj as? STSymptomTrackingAddedSymptomsResult,
            let addedSymptoms = self.addedSymptoms {
            result.addedSymptoms = addedSymptoms
            return result
        }
        return obj
    }
    
}
