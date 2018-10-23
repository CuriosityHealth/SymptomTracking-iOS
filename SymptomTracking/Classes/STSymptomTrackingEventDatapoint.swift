//
//  STSymptomTrackingEventDatapoint.swift
//  SymptomTracking
//
//  Created by James Kizer on 10/21/18.
//

import UIKit
import LS2SDK
import Gloss


public struct STSymptom: Glossy, Codable {
    public let identifier: String
    public let prompt: String
    public let text: String
    public let userDefined: Bool
    
    public static func createSymptom(json: JSON, userDefined: Bool) -> STSymptom? {
        guard let identifier: String = "identifier" <~~ json,
            let prompt: String = "prompt" <~~ json,
            let text: String = "text" <~~ json else {
                return nil
        }
        
        return STSymptom(
            identifier: identifier,
            prompt: prompt,
            text: text,
            userDefined: userDefined
        )
    }
    
    public init?(json: JSON) {
        guard let identifier: String = "identifier" <~~ json,
            let prompt: String = "prompt" <~~ json,
            let text: String = "text" <~~ json,
            let userDefined: Bool = "userDefined" <~~ json else {
                return nil
        }
        
        self.identifier = identifier
        self.prompt = prompt
        self.text = text
        self.userDefined = userDefined
    }
    
    public init(
        identifier: String,
        prompt: String,
        text: String,
        userDefined: Bool
        ) {
        self.identifier = identifier
        self.prompt = prompt
        self.text = text
        self.userDefined = userDefined
    }
    
    public func toJSON() -> JSON? {
        return jsonify([
            "identifier" ~~> self.identifier,
            "prompt" ~~> self.prompt,
            "text" ~~> self.text,
            "userDefined" ~~> self.userDefined
            ])
    }
}

public struct STRating: Glossy, Codable {
    
    public let identifier: String
    public let prompt: String
    public let value: Int
    
    public init?(json: JSON) {
        guard let identifier: String = "identifier" <~~ json,
            let prompt: String = "prompt" <~~ json,
            let value: Int = "value" <~~ json else {
                return nil
        }
        
        self.identifier = identifier
        self.prompt = prompt
        self.value = value
    }
    
    public init(
        identifier: String,
        prompt: String,
        value: Int
        ) {
        self.identifier = identifier
        self.prompt = prompt
        self.value = value
    }
    
    public func toJSON() -> JSON? {
        return jsonify([
            "identifier" ~~> self.identifier,
            "prompt" ~~> self.prompt,
            "value" ~~> self.value
            ])
    }
}

public struct STSympomSeverityRating: Glossy, Codable {
    
    let symptom: STSymptom
    let rating: STRating
    
    public init?(json: JSON) {
        guard let symptom: STSymptom = "symptom" <~~ json,
            let rating: STRating = "rating" <~~ json else {
                return nil
        }
        
        self.symptom = symptom
        self.rating = rating
    }
    
    public init(
        symptom: STSymptom,
        rating: STRating
        ) {
        self.symptom = symptom
        self.rating = rating
    }
    
    public func toJSON() -> JSON? {
        return jsonify([
            "symptom" ~~> self.symptom,
            "rating" ~~> self.rating
            ])
    }
    
}

public struct STSymptomSeverityRatingEvent: Codable {
    
    let startTime: Date
    let endTime: Date?
    let symptomSeverityRatings: [STSympomSeverityRating]
    
    public init(
        symptomSeverityRatings: [STSympomSeverityRating],
        startTime: Date,
        endTime: Date?
        ) {
        self.symptomSeverityRatings = symptomSeverityRatings
        self.startTime = startTime
        self.endTime = endTime
    }
}

extension STSymptomSeverityRatingEvent: Glossy {
    
    public init?(json: JSON) {
        guard let symptomSeverityRatingsJSON: [JSON] = "symptom_serverity_ratings" <~~ json,
            let timeFrame: JSON = "time_frame" <~~ json else {
                return nil
        }
        
        let (startTimeOpt, endTimeOpt): (Date?, Date?) = {
           
            if let dateTime = Gloss.Decoder.decode(dateISO8601ForKey: "date_time")(timeFrame) {
                return (dateTime, nil)
            }
            else if let timeInterval: JSON = "time_interval" <~~ timeFrame,
                let startTime = Gloss.Decoder.decode(dateISO8601ForKey: "start_date_time")(timeInterval) {
                
                let endTime: Date? = Gloss.Decoder.decode(dateISO8601ForKey: "end_date_time")(timeInterval)
                return (startTime, endTime)
            }
            else {
                return (nil, nil)
            }
            
        }()
        
        guard let startTime = startTimeOpt else {
            return nil
        }
        
        self.symptomSeverityRatings = symptomSeverityRatingsJSON.compactMap({ STSympomSeverityRating(json: $0) })
        self.startTime = startTime
        self.endTime = endTimeOpt
    }
    
    public func toJSON() -> JSON? {
        
        let timeFrame: JSON? = {
            if let endTime = self.endTime {
                return jsonify([
                    "time_interval" ~~> jsonify([
                        Gloss.Encoder.encode(dateISO8601ForKey: "start_date_time")(self.startTime),
                        Gloss.Encoder.encode(dateISO8601ForKey: "end_date_time")(endTime)
                        ])
                    ])
            }
            else {
                return jsonify([
                    Gloss.Encoder.encode(dateISO8601ForKey: "date_time")(self.startTime)
                    ])
            }
        }()
        
        return jsonify([
            "symptom_serverity_ratings" ~~> self.symptomSeverityRatings,
            "time_frame" ~~> timeFrame
            ])
    }
}

open class STSymptomTrackingEventDatapoint: NSObject, LS2Datapoint, LS2DatapointConvertible, LS2DatapointDecodable {
    
    public static var currentSchemaVersion: LS2SchemaVersion = LS2SchemaVersion(major: 1, minor: 0, patch: 0)
    public static var schemaName = "SymptomTrackingEvent"
    public static var schemaNamespace = "com.curiosityhealth.symptomtracking"
    
    public required init?(json: JSON) {
        guard let datapoint = LS2ConcreteDatapoint.init(json: json),
            let body = datapoint.body,
            let event = STSymptomSeverityRatingEvent(json: body) else {
            return nil
        }
        
        self.event = event
        self.proxyDatapoint = datapoint
        super.init()
    }
    
    public func toDatapoint(builder: LS2DatapointBuilder.Type) -> LS2Datapoint? {
        return builder.copyDatapoint(datapoint: self.proxyDatapoint)
    }
    
    //needs to be updated to ensure that datapoints are truly symptom tracking events
    static public func typeCheck(datapoint: LS2Datapoint) -> Bool {
        return true
    }
    
    required public init?(datapoint: LS2Datapoint) {
        guard STSymptomTrackingEventDatapoint.typeCheck(datapoint: datapoint),
            let proxyDatapoint = LS2ConcreteDatapoint.copyDatapoint(datapoint: datapoint),
            let body = datapoint.body,
            let event = STSymptomSeverityRatingEvent(json: body) else {
            return nil
        }
        
        self.event = event
        self.proxyDatapoint = proxyDatapoint
        super.init()
    }
    
    private let proxyDatapoint: LS2Datapoint
    
    public var header: LS2DatapointHeader? {
        return self.proxyDatapoint.header
    }
    
    public var body: JSON? {
        return self.proxyDatapoint.body
    }
    
    public func toJSON() -> JSON? {
        return self.proxyDatapoint.toJSON()
    }
    
    private let event: STSymptomSeverityRatingEvent
    
    public var startTime: Date {
        return self.event.startTime
    }

    public var endTime: Date? {
        return self.event.endTime
    }

    public var symptomSeverityRatings: [STSympomSeverityRating] {
        return self.event.symptomSeverityRatings
    }
    
    //needs uuid
    //needs time associated with it that differs from AP creation time
    //posssibly have duration associated with it?
    //store as omh time_frame, which can be either a point in time or an interval
    //http://www.openmhealth.org/documentation/#/schema-docs/schema-library/schemas/omh_time-frame
    
    public init(
        identifier: UUID,
        event: STSymptomSeverityRatingEvent,
        sourceCreationTime: Date = Date(),
        metadata: JSON? = nil
        ) {
        
        let schema = LS2Schema(
            name: STSymptomTrackingEventDatapoint.schemaName,
            version: STSymptomTrackingEventDatapoint.currentSchemaVersion,
            namespace: STSymptomTrackingEventDatapoint.schemaNamespace
        )
        
        let ap = LS2AcquisitionProvenance(
            sourceName: LS2AcquisitionProvenance.defaultAcquisitionSourceName,
            sourceCreationDateTime: sourceCreationTime,
            modality: .SelfReported
        )
        
        let header: LS2DatapointHeader = LS2DatapointHeader(
            id: identifier,
            schemaID: schema,
            acquisitionProvenance: ap
        )
        
        self.event = event
        let body: JSON = event.toJSON()!
        
        let datapoint: LS2ConcreteDatapoint = LS2ConcreteDatapoint(header: header, body: body)!
        
        self.proxyDatapoint = datapoint
        super.init()
    }

}
