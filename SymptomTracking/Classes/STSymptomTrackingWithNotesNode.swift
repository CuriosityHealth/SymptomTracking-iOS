//
//  STSymptomTrackingWithNotesNode.swift
//  SymptomTracking
//
//  Created by James Kizer on 11/24/18.
//

import UIKit
import ResearchKit
import ResearchSuiteApplicationFramework
import Gloss
import Mustache

open class STSymptomTrackingWithNotesNode: RSStepTreeBranchNode {
    
    //symptom tracking step descriptor
    let notesDescriptor: STSymptomTrackingNotesDescriptor
    let stepTreeBuilder: RSStepTreeBuilder
//    var children: [RSStepTreeNode]
    var symptomTrackingNode: RSStepTreeNode!
    public init(identifier: String, identifierPrefix: String, type: String, symptomTrackingStepDescriptor: JSON, notesDescriptor: STSymptomTrackingNotesDescriptor, parent: RSStepTreeNode?, stepTreeBuilder: RSStepTreeBuilder) {
        
//        self.notesNodeDescriptor = notesNodeDescriptor
        self.notesDescriptor = notesDescriptor
        self.stepTreeBuilder = stepTreeBuilder
        
//        self.children = []
        super.init(identifier: identifier, identifierPrefix: identifierPrefix, type: type, children: [], parent: parent, navigationRules: nil, resultTransforms: nil, valueMapping: nil)
        
        self.symptomTrackingNode = stepTreeBuilder.node(json: symptomTrackingStepDescriptor, identifierPrefix: "\(identifierPrefix).\(identifier)", parent: self)!
        self.setChildren(children: [self.symptomTrackingNode])
    }
    
//    open override func firstLeaf(with result: ORKTaskResult, state: RSState) -> RSStepTreeLeafNode? {
//
//        //
//        guard let child = self.stepTreeBuilder.node(json: self.symptomTrackingStepDescriptor, identifierPrefix: "\(self.identifierPrefix).\(self.identifier)", parent: self) else {
//            return nil
//        }
//
//        self.setChildren(children: [child])
//
//        return super.firstLeaf(with: result, state: state)
//    }
    
    func loadTemplate(descriptor: STSymptomTrackingNotesDescriptor, stepTreeBuilder: RSStepTreeBuilder) -> Template? {
        
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
    
    func generateNotesNode(notesDescriptor: STSymptomTrackingNotesDescriptor, result: STSymptomTrackingResult) -> RSStepTreeBranchNode? {
        
        guard let event = result.event,
            let template = self.loadTemplate(descriptor: notesDescriptor, stepTreeBuilder: self.stepTreeBuilder)else {
            return nil
        }
        
        let notesNodeIdentifierPrefix = "\(self.identifierPrefix).\(self.identifier)"
        let notesNodeIdentifier = "notes"
        
        let children: [RSStepTreeNode] = event.symptomSeverityRatings.compactMap { rating in
            print(rating)
            
            let firstPassSubstitutions: [String: Any] = [
                "symptom_prompt": rating.symptom.prompt,
                "severity_prompt": rating.rating.prompt
            ]
            
            let textTemplate = self.stepTreeBuilder.rstb.helper.localizationHelper.localizedString(notesDescriptor.noteTextTemplate)
            let placeholderTemplate = self.stepTreeBuilder.rstb.helper.localizationHelper.localizedString(notesDescriptor.notePlaceholderTemplate)
            
            guard let text = try? RSTemplatedStringValueTransformer.generateString(templatedString: textTemplate, substitutions: firstPassSubstitutions),
                let placeholder = try? RSTemplatedStringValueTransformer.generateString(templatedString: placeholderTemplate, substitutions: firstPassSubstitutions) else {
                    return nil
            }

            let parameters: [String: Any] = [
                "symptom_identifier": rating.symptom.identifier,
                "text": text,
                "placeholder": placeholder
            ]
            
            guard let renderedTemplate: String = (try? template.render(parameters)) else {
                return nil
            }
            
            guard let jsonData = renderedTemplate.data(using: .utf8),
                let json = (try! JSONSerialization.jsonObject(with: jsonData, options: [])) as? JSON else {
                    return nil
            }
            
            return self.stepTreeBuilder.node(json: json, identifierPrefix: "\(notesNodeIdentifierPrefix).\(notesNodeIdentifier)", parent: self)
        }
        
        if children.count > 0 {
            
            let node = RSStepTreeBranchNode(
                identifier: notesNodeIdentifier,
                identifierPrefix: notesNodeIdentifierPrefix,
                type: "notes",
                children: children,
                parent: self,
                navigationRules: nil,
                resultTransforms: nil,
                valueMapping: nil
            )
            
            return node
        }
        
        return nil
    }
    
    open override func child(after child: RSStepTreeNode?, with result: ORKTaskResult, state: RSState) -> RSStepTreeNode? {
        
        //if child is symptoms choice, get result and create the notes node and call doctor node
        if let child = child,
            child == self.symptomTrackingNode,
            let stepResult = result.stepResult(forStepIdentifier: "\(child.identifierPrefix).\(child.identifier)"),
            let symptomTrackingResult: STSymptomTrackingResult = stepResult.results?.first as? STSymptomTrackingResult {
            
            let notesBranchNode = self.generateNotesNode(notesDescriptor: self.notesDescriptor, result: symptomTrackingResult)
            
            let childNodes: [RSStepTreeNode] = [
                self.symptomTrackingNode,
                notesBranchNode
            ].compactMap({ $0 })
            
            self.setChildren(children: childNodes)
            
        }
        
        
        return super.child(after: child, with: result, state: state)
    }
    
    
    
//    let template: Template
//    let parameters: JSON?
    
//
//    public init(identifier: String, identifierPrefix: String, type: String, template: Template, parameters: JSON?, parent: RSStepTreeNode?, stepTreeBuilder: RSStepTreeBuilder) {
//        self.template = template
//        self.parameters = parameters
//        self.stepTreeBuilder = stepTreeBuilder
//        self.children = []
//        super.init(identifier: identifier, identifierPrefix: identifierPrefix, type: type, children: [], parent: parent, navigationRules: nil, resultTransforms: nil, valueMapping: nil)
//    }
//
//    open func generateParameters(result: ORKTaskResult, state: RSState) -> JSON? {
//
//        guard let parameters: JSON = self.parameters else {
//            return nil
//        }
//
//        var generatedParameters: JSON = [:]
//
//        let context: [String: AnyObject] = {
//            if let stateHelper = self.stepTreeBuilder.rstb.helper.stateHelper as? RSTaskBuilderStateHelper {
//                return stateHelper.extraStateValues.merging(["taskResult": result, "node": self.parent as AnyObject], uniquingKeysWith: { (obj1, obj2) -> AnyObject in
//                    return obj2
//                })
//            }
//            else {
//                return ["taskResult": result, "node": self.parent as AnyObject]
//            }
//        }()
//
//        parameters.keys.forEach { (key) in
//
//            guard let parameterJSON = parameters[key] as? JSON,
//                let parameterValueConvertible = RSValueManager.processValue(jsonObject: parameterJSON, state: state, context: context) else {
//                    return
//            }
//
//            let parameter: AnyObject? = {
//                if let parameterValue = parameterValueConvertible.evaluate() as? String {
//
//                    //try to localize string...
//                    let localizedParameterValue = self.stepTreeBuilder.rstb.helper.localizationHelper.localizedString(parameterValue)
//
//                    return localizedParameterValue.replacingOccurrences(of: "\t", with: "") as AnyObject
//                }
//                else {
//                    return parameterValueConvertible.evaluate()
//                }
//            }()
//
//            generatedParameters[key] = parameter
//        }
//
//        return generatedParameters
//    }
//
//    open override func firstLeaf(with result: ORKTaskResult, state: RSState) -> RSStepTreeLeafNode? {
//
//        //map data - I don't know how to do this just yet
//        let parameters = self.generateParameters(result: result, state: state)
//
//        //render template
//
//
//
//        guard let renderedTemplate: String = (try? self.template.render(parameters)) else {
//            return nil
//        }
//
//        //        print(renderedTemplate)
//        //convert to json
//        guard let jsonData = renderedTemplate.data(using: .utf8),
//            let json = (try! JSONSerialization.jsonObject(with: jsonData, options: [])) as? JSON else {
//                return nil
//        }
//
//        //generate nodes
//        guard let child = self.stepTreeBuilder.node(json: json, identifierPrefix: "\(self.identifierPrefix).\(self.identifier)", parent: self) else {
//            return nil
//        }
//
//        //set children
//        self.setChildren(children: [child])
//
//        //call super
//        return super.firstLeaf(with: result, state: state)
//    }

}
