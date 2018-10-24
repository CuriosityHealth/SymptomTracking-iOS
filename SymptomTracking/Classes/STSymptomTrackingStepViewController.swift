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

    enum STSymptomTrackingStepViewControllerErrors: Error {
        case unknownSymptom
        case unknownRating
        case malformedSelection
    }
    
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
        
//        guard let defaultTextChoices = self.symptomTrackingAnswerFormat.textChoices as? [RSTextChoiceWithAuxiliaryAnswer] else {
//                assertionFailure("Text choices must be of type RSTextChoiceWithAuxiliaryAnswer")
//                return
//        }
        
        let stepResult: ORKStepResult? = result as? ORKStepResult
        
        let symptomTrackingResult: STSymptomTrackingResult? = stepResult?.results?.first as? STSymptomTrackingResult
        
        let addedSymptoms = symptomTrackingResult?.addedSymptoms ?? []
        
        self.addedSymptoms = addedSymptoms
        
        var cellControllerMap: [Int: RSEnhancedMultipleChoiceCellController] = [:]
        
        let textChoices = self.symptoms.map { self.symptomTrackingAnswerFormat.textChoiceGenerator($0) }
        
        textChoices.enumerated().forEach { offset, textChoice in
            
            cellControllerMap[offset] = self.generateCellController(for: textChoice, choiceSelection: symptomTrackingResult?.choiceAnswer(for: textChoice.identifier) )
            
        }
        
        self.cellControllerMap = cellControllerMap
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()

        let addSymptomCellNIB = UINib(nibName: "STAddSymptomTableViewCell", bundle: Bundle(for: STAddSymptomTableViewCell.self))
        self.tableView.register(addSymptomCellNIB, forCellReuseIdentifier: "add_symptom")
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    var symptoms: [STSymptom] {
        return self.symptomTrackingAnswerFormat.symptoms + self.addedSymptoms
    }
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.symptomTrackingAnswerFormat.supportsAddingSymptoms {
            return self.symptoms.count + 1
        }
        else {
            return self.symptoms.count
        }
    }
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let symptoms = self.symptoms
        if self.symptomTrackingAnswerFormat.supportsAddingSymptoms &&
            row == symptoms.count {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "add_symptom", for: indexPath) as! STAddSymptomTableViewCell
            cell.selectionStyle = .none
            
            cell.button.setTitle("Add New Symptom", for: .normal)
            cell.onTap = { [unowned tableView] cell in
                self.startAdd(tableView: tableView)
            }
            
            return cell
            
        }
        else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
    }
    
    func addUserDefinedSymptom(symptomTitle: String, tableView: UITableView) {
        
        let duplicate = self.symptoms.contains(where: { $0.prompt == symptomTitle })
        
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
            let newIndex = self.symptoms.count - 1
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
    
    
    open func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if self.symptomTrackingAnswerFormat.supportsAddingSymptoms &&
            indexPath.row == self.symptoms.count {
            return nil
        }
        else {
            return indexPath
        }
    }
    
    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        if self.symptomTrackingAnswerFormat.supportsAddingSymptoms &&
            row == self.symptoms.count {
            tableView.deselectRow(at: indexPath, animated: true)
            
//            self.startAdd(tableView: tableView)
            
        }
        else {
            super.tableView(tableView, didSelectRowAt: indexPath)
        }
    }

    private var symptomMap: [String: STSymptom] {
        return Dictionary.init(uniqueKeysWithValues:  self.symptoms.map { ($0.identifier, $0) } )
    }
    
    private var ratingMap: [Int: STRating] {
        return Dictionary.init(uniqueKeysWithValues: self.symptomTrackingAnswerFormat.ratings.map { ($0.value, $0) } )
    }
    
    func symptom(for selection: RSEnahncedMultipleChoiceSelection, symptomMap: [String: STSymptom]) throws -> STSymptom {
        
        guard let symptom = symptomMap[selection.identifier] else {
            throw STSymptomTrackingStepViewControllerErrors.unknownSymptom
        }
        
        return symptom
    }
    
    func rating(for selection: RSEnahncedMultipleChoiceSelection, ratingMap: [Int: STRating]) throws -> STRating {
        
        //get value from aux item
        guard let auxItem = selection.auxiliaryResult,
            let textChoiceResult = auxItem as? ORKChoiceQuestionResult,
            let choiceAnswers = textChoiceResult.choiceAnswers else {
                throw STSymptomTrackingStepViewControllerErrors.malformedSelection
        }
        
        print(choiceAnswers)
        guard let choice = choiceAnswers.first as? ORKTextChoice,
            let ratingValue = choice.value as? NSNumber else {
            throw STSymptomTrackingStepViewControllerErrors.malformedSelection
        }
        
        let index = ratingValue.intValue
        //find rating associated with value
        guard let rating = ratingMap[index] else {
            throw STSymptomTrackingStepViewControllerErrors.unknownSymptom
        }
        
        return rating
    }
    
    override open var result: ORKStepResult? {
        guard let result = super.result else {
            return nil
        }

        let symptomTrackingResult = STSymptomTrackingResult(identifier: self.symptomTrackingStep.identifier)

        let selections = self.cellControllerMap.values.compactMap { (cellController) -> RSEnahncedMultipleChoiceSelection? in
            return cellController.choiceSelection
        }

        symptomTrackingResult.choiceAnswers = selections
        
        let event: STSymptomSeverityRatingEvent? = {
           
            let symptomMap = self.symptomMap
            let ratingMap = self.ratingMap
            let symptomSeverityRatingsOpt: [STSympomSeverityRating]? = try? selections.map { [unowned self] selection in
                let symptom = try self.symptom(for: selection, symptomMap: symptomMap)
                let rating = try self.rating(for: selection, ratingMap: ratingMap)
                return STSympomSeverityRating(symptom: symptom, rating: rating)
            }
            
            guard let symptomSeverityRatings = symptomSeverityRatingsOpt else {
                return nil
            }
            
            let event = STSymptomSeverityRatingEvent(
                symptomSeverityRatings: symptomSeverityRatings,
                startTime: result.startDate,
                endTime: nil
            )
            
            return event
        }()
        
        symptomTrackingResult.event = event
        symptomTrackingResult.addedSymptoms = self.addedSymptoms
        
        result.results = [symptomTrackingResult]
        
        return result
    }
}
