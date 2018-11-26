//
//  STSymptomManagementLayoutViewController.swift
//  SymptomTracking
//
//  Created by James Kizer on 10/23/18.
//

import UIKit
import ReSwift
import Gloss
//import CoreLocation
import ResearchSuiteTaskBuilder
import ResearchSuiteApplicationFramework

//open class STSymptomManagementLayoutViewControllerDataSource: NSObject, UITableViewDataSource, StoreSubscriber {
//
//    public let applicationDefinedSymptomsKey: String?
//    public let userDefinedSymptomsKey: String
//
//    public init(
//        userDefinedSymptomsKey: String,
//        applicationDefinedSymptomsKey: String?
//        ) {
//
//        self.userDefinedSymptomsKey = userDefinedSymptomsKey
//        self.applicationDefinedSymptomsKey = applicationDefinedSymptomsKey
//
//    }
//
//    var userDefinedSymptoms: [STSymptom] = []
//    var application
//    public func newState(state: RSState) {
//
//    }
//
//    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        <#code#>
//    }
//
//    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        <#code#>
//    }
//
//}

//extension Array where Element: NSObjectProtocol {
//    func computeChanges<T>(otherArray: Array<T>) -> ([Int], [Int], [Int]) {
//        return ([], [], [])
//    }
//}

open class STSymptomManagementLayoutViewController: UITableViewController, StoreSubscriber, RSSingleLayoutViewController {
    
    public var identifier: String! {
        return self.matchedRoute.route.identifier
    }
    
    public let uuid: UUID = UUID()
    
    public var matchedRoute: RSMatchedRoute!
    
    public var viewController: UIViewController! {
        return self
    }
    
    public var parentLayoutViewController: RSLayoutViewController!
    
    var state: RSState!
    weak var store: Store<RSState>? {
        return RSApplicationDelegate.appDelegate.store
    }
    
    var symptomManagementLayout: STSymptomManagementLayout! {
        return self.layout as! STSymptomManagementLayout
    }
    open var layout: RSLayout! {
        return self.matchedRoute.layout
    }
    
    var hasAppeared: Bool = false
    
    var _applicationDefinedSymptoms: [STSymptom]?
    var applicationDefinedSymptoms: [STSymptom] {
        get {
            if let symptoms = self._applicationDefinedSymptoms {
                return symptoms
            }
            else {
                let applicationDefinedSymptoms: [STSymptom] = {
                    
                    if let applicationDefinedSymptomsKey = self.symptomManagementLayout.applicationDefinedSymptomsKey,
                        let jsonArray = RSStateSelectors.getValueInCombinedState(self.state, for: applicationDefinedSymptomsKey) as? [JSON] {
                        return jsonArray.compactMap { STSymptom(json: $0) }
                    }
                    else {
                        return []
                    }
                    
                }()
                self._applicationDefinedSymptoms = applicationDefinedSymptoms
                return applicationDefinedSymptoms
            }
        }
    }
    
    private func getUserDefinedSymptomsFromState(state: RSState) -> [STSymptom] {
        let userDefinedSymptomsKey = self.symptomManagementLayout.userDefinedSymptomsKey
        if let jsonArray = RSStateSelectors.getValueInCombinedState(self.state, for: userDefinedSymptomsKey) as? [JSON] {
            return jsonArray.compactMap { STSymptom(json: $0) }
        }
        else {
            return []
        }
    }
    
    var _userDefinedSymptoms: [STSymptom]?
    var userDefinedSymptoms: [STSymptom] {
        get {
            if let symptoms = self._userDefinedSymptoms {
                return symptoms
            }
            else {
                let userDefinedSymptoms = self.getUserDefinedSymptomsFromState(state: state)
                self._userDefinedSymptoms = userDefinedSymptoms
                return userDefinedSymptoms
            }
        }
        set(newSymptoms) {
            
            self._userDefinedSymptoms = newSymptoms
            //clear symptoms so that it will be reloaded on next use
            self._symptoms = nil
            
            //convert new symptoms to JSON
            let jsonArray: [JSON] = newSymptoms.compactMap { $0.toJSON() }
            let userDefinedSymptomsKey = self.symptomManagementLayout.userDefinedSymptomsKey
            let action = RSActionCreators.setValueInState(key: userDefinedSymptomsKey, value: jsonArray as NSArray)
            self.store?.dispatch(action)
            
        }
    }
    
    var _symptoms:[STSymptom]?
    var symptoms:[STSymptom] {
        if let symptoms = self._symptoms {
            return symptoms
        }
        else {
            let symptoms = self.applicationDefinedSymptoms + self.userDefinedSymptoms
            self._symptoms = symptoms
            return symptoms
        }
    }
    
    open func initializeNavBar() {
        
        self.navigationItem.title = self.localizationHelper.localizedString(self.layout.navTitle)
        
        let onTap: (RSBarButtonItem) -> () = { [unowned self] button in
            button.layoutButton.onTapActions.forEach { self.processAction(action: $0) }
        }
        
        
        let rightBarButtonItems = self.layout.rightNavButtons?.compactMap { (layoutButton) -> UIBarButtonItem? in
            return RSBarButtonItem(layoutButton: layoutButton, onTap: onTap, localizationHelper: self.localizationHelper)
        }
        
        self.navigationItem.rightBarButtonItems = (rightBarButtonItems ?? []) + [self.editButtonItem]
        
    }
    
    open func reloadLayout() {
        
        self.initializeNavBar()
        self.tableView?.reloadData()
        self.childLayoutVCs.forEach({ $0.reloadLayout() })
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.store?.subscribe(self)
        
        self.initializeNavBar()

        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "default")
        
        self.refreshControl?.isEnabled = false
        
        self.layoutDidLoad()
    }
    
    deinit {
        self.store?.unsubscribe(self)
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.layoutDidAppear(initialAppearance: !self.hasAppeared)
        self.hasAppeared = true
    }
    
    //    @objc
    //    func tappedRightBarButton() {
    //        guard let button = self.layout.navButtonRight else {
    //            return
    //        }
    //
    //        button.onTapActions.forEach { self.processAction(action: $0) }
    //    }
    
    open func backTapped() {
        self.layout.onBackActions.forEach { self.processAction(action: $0) }
    }
    
    open func processAction(action: JSON) {
        if let store = self.store {
            store.processAction(action: action, context: ["layoutViewController":self], store: store)
        }
    }
    
    open func newState(state: RSState) {
        
        self.state = state
        
        assert(self.userDefinedSymptoms == self.getUserDefinedSymptomsFromState(state: state), "User-defined symptoms don't match. Did they somehow change outside of this layout?")
        
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override open func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.symptoms.count + 1
    }

    override open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "default", for: indexPath)
        
        cell.selectionStyle = .none
        
        let symptoms = self.symptoms
        let row = indexPath.row
        
        if row < symptoms.count {
            let item = symptoms[indexPath.row]
            
            cell.textLabel?.text = item.prompt
            cell.textLabel?.textColor = UIColor.black
            cell.detailTextLabel?.text = item.text
            
        }
        else {
            
//            cell.textLabel?.text = "Add New Symptom"
//            cell.textLabel?.textColor = self.view.tintColor
//            cell.detailTextLabel?.text = nil
            cell.textLabel?.text = nil
            cell.detailTextLabel?.text = nil
            
        }
        
        return cell
        
    }
    
    // Override to support conditional editing of the table view.
    override open func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        
        //if app defined symtptoms, return false
        if indexPath.row < self.applicationDefinedSymptoms.count {
            return false
        }
        else {
            return true
        }
    }
    
    override open func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if indexPath.row < self.applicationDefinedSymptoms.count {
            return .none
        }
        else if indexPath.row < self.symptoms.count {
            return .delete
        }
        else {
            return .insert
        }
        
    }
    
    // Override to support editing the table view.
    override open func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let row = indexPath.row
            let userDefinedSymptomIndex = row - self.applicationDefinedSymptoms.count
            let symptomToRemove = self.userDefinedSymptoms[userDefinedSymptomIndex]
            
            self.userDefinedSymptoms = self.userDefinedSymptoms.filter { $0.identifier != symptomToRemove.identifier }
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        else if editingStyle == .insert {
            self.startAdd()
        }
    }
    
    override open func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
//        if indexPath.row >= self.applicationDefinedSymptoms.count {
//            return indexPath
//        }
//        else {
//            return nil
//        }
        return nil
    }
    
    func startAdd() {
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
            
            self.addUserDefinedSymptom(symptomTitle: symptomTitle)
        }
        
        alertController.addAction(submitAction)
        
        // Replace UIAlertActionStyle.Default by UIAlertActionStyle.default
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { (result : UIAlertAction) -> Void in
            
        }
        
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        let row = indexPath.row
        if row == self.symptoms.count {
            
            self.startAdd()
            
        }
        
    }
    
    func addUserDefinedSymptom(symptomTitle: String) {
        
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
            self.userDefinedSymptoms = self.userDefinedSymptoms + [newSymptom]
            
            let newIndexPath = IndexPath(row: self.symptoms.count - 1, section: 0)
            
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: [newIndexPath], with: .automatic)
            self.tableView.endUpdates()
        }
        
    }
    
    
    open func layoutDidLoad() {
        
        self.layout.onLoadActions.forEach({ (action) in
            if let store = self.store {
                store.processAction(action: action, context: ["layoutViewController":self], store: store)
            }
        })
        
    }
    
    open func layoutDidAppear(initialAppearance: Bool) {
        
        if initialAppearance {
            self.layout.onFirstAppearanceActions.forEach({ (action) in
                if let store = self.store {
                    store.processAction(action: action, context: ["layoutViewController":self], store: store)
                }
            })
        }
        
    }
    
    public var childLayoutVCs: [RSLayoutViewController] = []
    
    public func childLayoutVC(for matchedRoute: RSMatchedRoute) -> RSLayoutViewController? {
        
        return childLayoutVCs.first(where: { (lvc) -> Bool in
            return lvc.matchedRoute.route.identifier == matchedRoute.route.identifier
        })
        
    }
    
    public func updateLayout(matchedRoute: RSMatchedRoute, state: RSState) {
        
    }
    
    
    
}
