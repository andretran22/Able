//
//  FilterVC.swift
//  Able
//
//  Created by Andre Tran on 11/3/20.
//

import UIKit

class FilterVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate, SelectedButtonDelegate, CustomTagDelegate {
    
    //text fields
    @IBOutlet weak var sortField: UITextField!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var tagsField: UITextField!
    
    //buttons
    @IBOutlet weak var foodButton: SelectionButton!
    @IBOutlet weak var waterButton: SelectionButton!
    @IBOutlet weak var toysButtons: SelectionButton!
    @IBOutlet weak var clothesButton: SelectionButton!
    @IBOutlet weak var toiletriesButton: SelectionButton!
    @IBOutlet weak var medicineButton: SelectionButton!
    @IBOutlet weak var furnitureButton: SelectionButton!
    @IBOutlet weak var techButton: SelectionButton!
    @IBOutlet weak var otherButton: SelectionButton!
    
    // display collection of tags
    @IBOutlet weak var collectionTags: UICollectionView!
    let tagIdentifier = "TagCellId"
    var searchTags = Array<String>()
    
    //dropdown for sort by
    var selectedCountry: String?
    var sortOptions = ["Most Recent", "Oldest"]
    
    //track selected "Quick categories"
    var categoriesSelected = Set<String>()
    
    // delegate to send filter properties back to home page
//    var returnDelegate: ReturnFilterDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
        createPickerView()
        dismissPickerView()
        sortField.text = "Most Recent"
        locationField.text = ""
        
        foodButton.selectDelegate = self
        waterButton.selectDelegate = self
        toysButtons.selectDelegate = self
        clothesButton.selectDelegate = self
        toiletriesButton.selectDelegate = self
        medicineButton.selectDelegate = self
        furnitureButton.selectDelegate = self
        techButton.selectDelegate = self
        otherButton.selectDelegate = self
        
        collectionTags.delegate = self
        collectionTags.dataSource = self
        self.tagsField.delegate = self
        self.locationField.delegate = self
    }
    
    
    
    //MARK: - Next 7 methods for drop down menu for "Sort By" field
    
    func createPickerView() {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        sortField.inputView = pickerView
    }

    func dismissPickerView() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let button = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.action))
        toolBar.setItems([button], animated: true)
        toolBar.isUserInteractionEnabled = true
        sortField.inputAccessoryView = toolBar
    }

    @objc func action() {
        view.endEditing(true)
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return sortOptions.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return sortOptions[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        sortField.text = sortOptions[row]
    }
    
    

    // MARK: - Delegate methods for collection view of "Custom Tag" display
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        searchTags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: tagIdentifier, for: indexPath as IndexPath) as! MyCategoryCell
        
        cell.customTagLabel.text = searchTags[indexPath.row]
        cell.customTagDelegate = self
        return cell
    }
    
    // delete item from collection view display
    func deleteTagItem(tagToDelete: String) {
        if let index = searchTags.firstIndex(of: tagToDelete) {
            searchTags.remove(at: index)
        }
        collectionTags.reloadData()
    }
    
    // When keyboard return/enter key pressed action
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == tagsField {
            let text = textField.text!
            checkForDuplicateAndInsert(find: text)
            textField.text = ""
            textField.resignFirstResponder()
            return false
        }
        if textField == locationField {
            textField.resignFirstResponder()
        }
        return true
    }
    
    // Check tag for duplicate and insert if not.
    func checkForDuplicateAndInsert(find:String){
        guard find != "" else {return}
        for word in searchTags {
            if find.lowercased() == word.lowercased() {
                return
            }
        }
        searchTags.append(find)
        collectionTags.reloadData()
    }
    

    
    // MARK: - Delegate Methods for the "Quick Category" buttons
    
    func setCategory(name: String) {
        categoriesSelected.insert(name)
        print(categoriesSelected)
    }
    
    func removeCategory(name: String) {
        categoriesSelected.remove(name)
        print(categoriesSelected)
    }
    
    
    
    //MARK: - Helper functions
    
    // dismiss keyboard when touched outside of it
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    // set global filter state right before view disappears
    override func viewWillDisappear(_ animated: Bool) {
        globalFilterState = CurrentFilters(sort: sortField.text!,
                                           location: locationField.text!,
                                           tags: Array(searchTags),
                                           categories: Array(categoriesSelected))
                
    }

}

