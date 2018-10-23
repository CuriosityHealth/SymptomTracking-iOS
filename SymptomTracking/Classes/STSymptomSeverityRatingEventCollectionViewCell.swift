//
//  STSymptomSeverityRatingEventCollectionViewCell.swift
//  SymptomTracking
//
//  Created by James Kizer on 10/23/18.
//

import UIKit
import ResearchSuiteApplicationFramework
import Gloss

open class STSymptomSeverityRatingEventCollectionViewCell: RSTextCardCollectionViewCell {
    
    
    open override class var identifier: String {
        return "symptomSeverityRatingEventCell"
    }
    
    open override class var collectionViewCellClass: AnyClass {
        return STSymptomSeverityRatingEventCollectionViewCell.self
    }
    
    override open func configure(paramMap: [String : Any]) {
        
        super.configure(paramMap: paramMap)
        
        guard let eventJSON = paramMap["symptomSeverityRatingEvent"] as? JSON,
            let symptomSeverityRatingEvent = STSymptomSeverityRatingEvent(json: eventJSON) else {
                return
        }

        let includedSymptomIdentifiers: Set<String>? = {
            if let identifiers = paramMap["includedSymptomIdentifiers"] as? [String] {
                return Set(identifiers)
            }
            return nil
        }()
        
        let includedRatingIdentifiers: Set<String>? = {
            if let identifiers = paramMap["includedRatingIdentifiers"] as? [String] {
                return Set(identifiers)
            }
            return nil
        }()
            
        //subtitle - timestamp
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .medium
        
        self.subtitleLabel.text = dateFormatter.string(from: symptomSeverityRatingEvent.startTime)
        
        var filteredSymptomSeverityRatings = symptomSeverityRatingEvent.symptomSeverityRatings
        
        if let symptomIdentifiers = includedSymptomIdentifiers {
            filteredSymptomSeverityRatings = filteredSymptomSeverityRatings.filter { symptomIdentifiers.contains($0.symptom.identifier) }
        }
        
        if let ratingIdentifiers = includedRatingIdentifiers {
            filteredSymptomSeverityRatings = filteredSymptomSeverityRatings.filter { ratingIdentifiers.contains($0.rating.identifier) }
        }
        
        let sentences: [String] = filteredSymptomSeverityRatings.map { symptomSeverityRating in

            let symptom = symptomSeverityRating.symptom.prompt
            let severity = symptomSeverityRating.rating.prompt
            
            return "Your \(symptom) was \(severity)"
        }
        
        let bodyText = sentences.joined(separator: "\n")
        self.bodyTextLabel.text = bodyText
        
    }
    
}
