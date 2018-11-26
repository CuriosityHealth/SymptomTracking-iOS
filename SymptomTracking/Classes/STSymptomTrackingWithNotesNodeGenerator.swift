//
//  STSymptomTrackingWithNotesNodeGenerator.swift
//  SymptomTracking
//
//  Created by James Kizer on 11/24/18.
//

import UIKit
import Gloss
import ResearchSuiteApplicationFramework
import Mustache

open class STSymptomTrackingWithNotesNodeGenerator: RSStepTreeNodeGenerator {
    public static func supportsType(type: String) -> Bool {
        return "symptomTrackingWithNotes" == type
    }
    
    static func loadTemplate(descriptor: STSymptomTrackingNotesDescriptor, stepTreeBuilder: RSStepTreeBuilder) -> Template? {
        
        //first, try to load from URL (base + path)
        if let urlBase = stepTreeBuilder.rstb.helper.stateHelper?.valueInState(forKey: descriptor.templateURLBaseKey) as? String,
            let urlPath = descriptor.templateURLPath,
            let url = URL(string: urlBase + urlPath) {
            
            do {
                return try Template(URL: url)
            }
            catch let error {
                debugPrint(error)
                return nil
            }
            
            
        }
        else if let filename = descriptor.templateFilename {
            do {
                return try Template(path: filename)
            }
            catch let error {
                debugPrint(error)
                return nil
            }
        }
        else {
            return nil
        }
    }
    
    public static func generateNode(jsonObject: JSON, stepTreeBuilder: RSStepTreeBuilder, identifierPrefix: String, parent: RSStepTreeNode?) -> RSStepTreeNode? {
        
        guard let descriptor = STSymptomTrackingWithNotesNodeDescriptor(json: jsonObject) else {
            return nil
        }
        
        let node = STSymptomTrackingWithNotesNode(
            identifier: descriptor.identifier,
            identifierPrefix: identifierPrefix,
            type: descriptor.type,
            symptomTrackingStepDescriptor: descriptor.symptomTrackingStepDescriptor,
            notesDescriptor: descriptor.notesDescriptor,
            parent: parent,
            stepTreeBuilder: stepTreeBuilder
        )
        
        return node
    }
}
