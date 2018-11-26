//
//  STSymptomTrackingWithNotesNodeDescriptor.swift
//  SymptomTracking
//
//  Created by James Kizer on 11/24/18.
//

import UIKit
import ResearchSuiteTaskBuilder
import Gloss


public struct STSymptomTrackingNotesDescriptor: JSONDecodable {
    
    public let templateFilename: String?
    public let templateURLPath: String?
    public let templateURLBaseKey: String
    
    public let noteTextTemplate: String
    public let notePlaceholderTemplate: String
    
    public init?(json: JSON) {
        
        guard let noteTextTemplate: String = "noteTextTemplate" <~~ json,
            let notePlaceholderTemplate: String = "notePlaceholderTemplate" <~~ json else {
                return nil
        }
        
        self.templateFilename = "templateFileName" <~~ json
        self.templateURLBaseKey = "templateURLBaseKey" <~~ json ?? "configJSONBaseURL"
        self.templateURLPath = "templateURLPath" <~~ json
        self.noteTextTemplate = noteTextTemplate
        self.notePlaceholderTemplate = notePlaceholderTemplate
    }
    
}

open class STSymptomTrackingWithNotesNodeDescriptor: RSTBElementDescriptor {
    
    let symptomTrackingStepDescriptor: JSON
    let notesDescriptor: STSymptomTrackingNotesDescriptor
    
    required public init?(json: JSON) {
        
        guard let symptomTrackingStepDescriptor: JSON = "symptomTrackingStep" <~~ json,
            let notesDescriptor: STSymptomTrackingNotesDescriptor = "notes" <~~ json else {
            return nil
        }
        
        self.symptomTrackingStepDescriptor = symptomTrackingStepDescriptor
        self.notesDescriptor = notesDescriptor
        
        super.init(json: json)
    }

}
