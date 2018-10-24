//
//  STSymptomManagementLayout.swift
//  SymptomTracking
//
//  Created by James Kizer on 10/23/18.
//

import UIKit
import ResearchSuiteApplicationFramework
import Gloss

open class STSymptomManagementLayout: RSBaseLayout, RSLayoutGenerator {
    
    public static func supportsType(type: String) -> Bool {
        return type == "symptomManagement"
    }
    
    public static func generate(jsonObject: JSON, layoutManager: RSLayoutManager, state: RSState) -> RSLayout? {
        return STSymptomManagementLayout(json: jsonObject)
    }
    
    public let applicationDefinedSymptomsKey: String?
    public let userDefinedSymptomsKey: String
    
    required public init?(json: JSON) {
        
        guard let userDefinedSymptomsKey: String = "userDefinedSymptomsKey" <~~ json else {
            return nil
        }
        
        self.userDefinedSymptomsKey = userDefinedSymptomsKey
        self.applicationDefinedSymptomsKey = "applicationDefinedSymptomsKey" <~~ json
        
        super.init(json: json)
    }
    
    open override func isEqualTo(_ object: Any) -> Bool {
        
        assertionFailure()
        return false
        
    }
    
    open override func instantiateViewController(parent: RSLayoutViewController, matchedRoute: RSMatchedRoute) throws -> RSLayoutViewController {
        
        let layoutVC = STSymptomManagementLayoutViewController()
        
        layoutVC.matchedRoute = matchedRoute
        layoutVC.parentLayoutViewController = parent
        
        return layoutVC
        
    }
    
}
