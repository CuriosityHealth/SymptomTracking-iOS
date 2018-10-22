//
//  STSymptomTrackingStepDescriptor.swift
//  SymptomTracking
//
//  Created by James Kizer on 10/21/18.
//

import UIKit
import ResearchSuiteTaskBuilder
import Gloss
import ResearchSuiteExtensions

open class STSymptomTrackingStepDescriptor: RSTBStepDescriptor {
    
    public let formattedTitle: RSTemplatedTextDescriptor?
    public let formattedText: RSTemplatedTextDescriptor?
    
    //could require these items from the store
    public let applicationDefinedSymptomsKey: String?
    public let userDefinedSymptomsKey: String?
    public let ratingOptionsKey: String
    public let ratingPrompt: String?
    
    public let supportsAddingSymptoms: Bool

    required public init?(json: JSON) {
        
        guard let serverityOptionsKey: String = "ratingOptionsKey" <~~ json else {
            return nil
        }
        
        self.formattedTitle = "formattedTitle" <~~ json
        self.formattedText = "formattedText" <~~ json
        
        self.applicationDefinedSymptomsKey = "applicationDefinedSymptomsKey" <~~ json
        self.userDefinedSymptomsKey = "userDefinedSymptomsKey" <~~ json
        self.ratingOptionsKey = serverityOptionsKey
        self.ratingPrompt = "ratingPrompt" <~~ json
        
        self.supportsAddingSymptoms = "supportsAddingSymptoms" <~~ json ?? false
        
        super.init(json: json)
        
    }
    
}
