//
//  STSymptomTrackingEventIntermediateResult.swift
//  SymptomTracking
//
//  Created by James Kizer on 10/22/18.
//

import UIKit
import ResearchSuiteResultsProcessor
import ResearchKit
import Gloss
import LS2SDK

open class STSymptomTrackingEventIntermediateResult: RSRPIntermediateResult, RSRPFrontEndTransformer {
    
    public static func supportsType(type: String) -> Bool {
        return type == "symptomTrackingEvent"
    }
    
    public static func transform(taskIdentifier: String, taskRunUUID: UUID, parameters: [String : AnyObject]) -> RSRPIntermediateResult? {
        return nil
    }
    
    public let event: STSymptomSeverityRatingEvent
    
    public init(
        uuid: UUID,
        taskIdentifier: String,
        taskRunUUID: UUID,
        event: STSymptomSeverityRatingEvent
        ) {
        
        self.event = event
        
        super.init(
            type: "STSymptomTrackingEventResult",
            uuid: uuid,
            taskIdentifier: taskIdentifier,
            taskRunUUID: taskRunUUID
        )
    }
    
}

extension STSymptomTrackingEventIntermediateResult: LS2DatapointConvertible {
    public func toDatapoint(builder: LS2DatapointBuilder.Type) -> LS2Datapoint? {
        
        let datapoint = STSymptomTrackingEventDatapoint(
            identifier: self.uuid,
            event: self.event,
            sourceCreationTime: self.startDate ?? Date(),
            metadata: nil
        )
        
        return builder.copyDatapoint(datapoint: datapoint)
        
    }
    
}
