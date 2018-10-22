//
//  STSymptomTrackingStepViewController.swift
//  SymptomTracking
//
//  Created by James Kizer on 10/21/18.
//

import UIKit
import ResearchSuiteExtensions
import ResearchKit

open class STSymptomTrackingStepViewController: RSEnhancedMultipleChoiceStepViewController {

    
    var symptomTrackingStep: STSymptomTrackingStep {
        return self.step as! STSymptomTrackingStep
    }
    
    var symptomTrackingAnswerFormat: STSymptomTrackingAnswerFormat {
        return self.symptomTrackingStep.answerFormat as! STSymptomTrackingAnswerFormat
    }
    
    var addedSymptoms: [STSymptom] = []
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Do any additional setup after loading the view.
//    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.symptomTrackingAnswerFormat.supportsAddingSymptoms {
            return self.symptomTrackingAnswerFormat.textChoices.count + self.addedSymptoms.count + 1
        }
        else {
            return self.symptomTrackingAnswerFormat.textChoices.count
        }
    }

    override open var result: ORKStepResult? {
        guard let result = super.result else {
            return nil
        }

        let multipleChoiceResult = RSEnhancedMultipleChoiceResult(identifier: self.symptomTrackingStep.identifier)

        let selections = self.cellControllerMap.values.compactMap { (cellController) -> RSEnahncedMultipleChoiceSelection? in
            return cellController.choiceSelection
        }

        multipleChoiceResult.choiceAnswers = selections

        result.results = [multipleChoiceResult]

        return result
    }
}
