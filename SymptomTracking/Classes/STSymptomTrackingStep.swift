//
//  STSymptomTrackingStep.swift
//  SymptomTracking
//
//  Created by James Kizer on 10/21/18.
//

import UIKit
import ResearchSuiteExtensions

open class STSymptomTrackingStep: RSEnhancedMultipleChoiceStep {

    override open func stepViewControllerClass() -> AnyClass {
        return STSymptomTrackingStepViewController.self
    }
    
}
