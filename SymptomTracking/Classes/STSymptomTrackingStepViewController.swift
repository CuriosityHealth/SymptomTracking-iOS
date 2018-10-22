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
//    func getTextChoices(addedSymptoms: [STSymptom], auxItem)
    
//    override open func getTextChoices(step: ORKStep?, result: ORKResult?) -> [RSTextChoiceWithAuxiliaryAnswer]? {
//        if self.symptomTrackingAnswerFormat.supportsAddingSymptoms {
//            //TODO: map in new text choices to new symptoms
//            return self.symptomTrackingAnswerFormat.textChoices as? [RSTextChoiceWithAuxiliaryAnswer]
//        }
//        else {
//            return super.getTextChoices(step: step, result: result)
//        }
//    }
    
    open override func initializeCellControllerMap(step: ORKStep?, result: ORKResult?) {
        
        //here, we can initialize our addedSymptoms array based on results
        
        guard let defaultTextChoices = self.symptomTrackingAnswerFormat.textChoices as? [RSTextChoiceWithAuxiliaryAnswer] else {
                assertionFailure("Text choices must be of type RSTextChoiceWithAuxiliaryAnswer")
                return
        }
        
        let stepResult: ORKStepResult? = result as? ORKStepResult
        let choiceResult: RSEnhancedMultipleChoiceResult? = stepResult?.results?.first as? RSEnhancedMultipleChoiceResult
        
        let addedSymptoms: [STSymptom] = {
            
            if let results = stepResult?.results,
                results.count > 1,
                let addedSymptomsResult = results[1] as? STSymptomTrackingAddedSymptomsResult,
                let addedSymptoms = addedSymptomsResult.addedSymptoms {
                return addedSymptoms
            }
            else {
                return []
            }
            
        }()
        
        self.addedSymptoms = addedSymptoms
        
        var cellControllerMap: [Int: RSEnhancedMultipleChoiceCellController] = [:]
        
        let textChoices = defaultTextChoices + self.addedSymptoms.map { self.symptomTrackingAnswerFormat.textChoiceGenerator($0) }
        
        textChoices.enumerated().forEach { offset, textChoice in
            
            cellControllerMap[offset] = self.generateCellController(for: textChoice, choiceSelection: choiceResult?.choiceAnswer(for: textChoice.identifier) )
            
        }
        
        self.cellControllerMap = cellControllerMap
    }
    
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
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        if self.symptomTrackingAnswerFormat.supportsAddingSymptoms &&
            row == self.symptomTrackingAnswerFormat.textChoices.count + self.addedSymptoms.count {
            
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "default")
//            cell.snp.makeConstraints { (make) in
//                make.height.equalTo(60)
//            }
            cell.textLabel?.text = "Add New Symptom"
            cell.textLabel?.textColor = self.view.tintColor
            cell.detailTextLabel?.text = nil
            return cell
            
        }
        else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
    }
    
    func addUserDefinedSymptom(symptomTitle: String, tableView: UITableView) {
        
        let duplicate = self.addedSymptoms.contains(where: { $0.prompt == symptomTitle }) || self.symptomTrackingAnswerFormat.textChoices.contains(where: { $0.text == symptomTitle })
        
        if duplicate {
            
            let alertController = UIAlertController(title: "Unable To Add Symptom", message: "This symptom already exists.", preferredStyle: UIAlertController.Style.alert)
            
            // Replace UIAlertActionStyle.Default by UIAlertActionStyle.default
            let okayAction = UIAlertAction(title: "Okay", style: UIAlertAction.Style.cancel) {
                (result : UIAlertAction) -> Void in
                
            }
            
            alertController.addAction(okayAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
        else {
            let newSymptom = STSymptom(identifier: symptomTitle, prompt: symptomTitle, text: symptomTitle, userDefined: true)
            self.addedSymptoms = self.addedSymptoms + [newSymptom]
//            let newIndexPath = IndexPath(row: self.symptoms.count - 1, section: 0)
            let newIndex = self.symptomTrackingAnswerFormat.textChoices.count + self.addedSymptoms.count - 1
            let newIndexPath = IndexPath(row: newIndex, section: 0)
            
            let newTextChoice = self.symptomTrackingAnswerFormat.textChoiceGenerator(newSymptom)
            
            //need to update the cell controller map
//            self.updateCellControllerMap(step: self.step, result: self.result)
            self.cellControllerMap[newIndex] = self.generateCellController(for: newTextChoice, choiceSelection: nil)
            
            tableView.beginUpdates()
            tableView.insertRows(at: [newIndexPath], with: .automatic)
            tableView.endUpdates()
        }
        
        
        
    }
    
    func startAdd(tableView: UITableView) {
        let alertController = UIAlertController(title: "Add New Symptom", message: "Plase give the symptom a title.", preferredStyle: UIAlertController.Style.alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Symptom Title (e.g., Anxiety)"
        }
        
        // Replace UIAlertActionStyle.Default by UIAlertActionStyle.default
        let submitAction = UIAlertAction(title: "Submit", style: UIAlertAction.Style.default) { [unowned self, alertController] (result : UIAlertAction) -> Void in
            guard let textField = alertController.textFields?.first,
                let symptomTitle = textField.text else {
                    return
            }
            
            self.addUserDefinedSymptom(symptomTitle: symptomTitle, tableView: tableView)
        }
        
        alertController.addAction(submitAction)
        
        // Replace UIAlertActionStyle.Default by UIAlertActionStyle.default
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { (result : UIAlertAction) -> Void in
            
        }
        
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        if self.symptomTrackingAnswerFormat.supportsAddingSymptoms &&
            row == self.symptomTrackingAnswerFormat.textChoices.count + self.addedSymptoms.count {
            tableView.deselectRow(at: indexPath, animated: true)
            
            self.startAdd(tableView: tableView)
            
        }
        else {
            super.tableView(tableView, didSelectRowAt: indexPath)
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

        if self.symptomTrackingAnswerFormat.supportsAddingSymptoms {
            let addedSymptomsResult = STSymptomTrackingAddedSymptomsResult(identifier: "addedSymptoms")
            addedSymptomsResult.addedSymptoms = self.addedSymptoms
            result.results = [multipleChoiceResult, addedSymptomsResult]
        }
        else {
            result.results = [multipleChoiceResult]
        }
        
        return result
    }
}
