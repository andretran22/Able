//
//  FilterVC.swift
//  Able
//
//  Created by Andre Tran on 11/3/20.
//

import UIKit

class FilterVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate, SelectedButtonDelegate, CustomTagDelegate, ChangeLocation {
    
    
    //text fields
    @IBOutlet weak var sortField: UITextField!
//    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var tagsField: UITextField!
    var location:String = ""
    
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
    @IBOutlet weak var locationButton: UIButton!
    
    // display collection of tags
    @IBOutlet weak var collectionTags: UICollectionView!
    let tagIdentifier = "TagCellId"
    var searchTags = Array<String>()
    
    //dropdown for sort by
    var selectedCountry: String?
    var sortOptions = ["Most Recent", "Oldest"]
    
    //track selected "Quick categories"
    var categoriesSelected = Set<String>()
    
    //map name of button to button objects
    var buttonMap = [String: SelectionButton]()

    override func viewDidLoad() {
        super.viewDidLoad()
        createPickerView()
        dismissPickerView()
        
        sortField.text = globalFilterState?.sort 
        changeLocation(location: globalFilterState!.location)
        searchTags = globalFilterState?.tags ?? []
        categoriesSelected =  Set ( globalFilterState?.categories ?? [])
        

        foodButton.selectDelegate = self
        waterButton.selectDelegate = self
        toysButtons.selectDelegate = self
        clothesButton.selectDelegate = self
        toiletriesButton.selectDelegate = self
        medicineButton.selectDelegate = self
        furnitureButton.selectDelegate = self
        techButton.selectDelegate = self
        otherButton.selectDelegate = self
        
        buttonMap = [
            "Food" : foodButton,
            "Water": waterButton,
            "Toys": toysButtons,
            "Clothes": clothesButton,
            "Toiletries": toiletriesButton,
            "Medicine": medicineButton,
            "Furniture": furnitureButton,
            "Tech": techButton,
            "Other": otherButton
        ]
        setPrevState()

        collectionTags.delegate = self
        collectionTags.dataSource = self
        self.tagsField.delegate = self
    }
    
  
    func setPrevState() {
        for category in categoriesSelected {
            buttonMap[category]?.active = true
            buttonMap[category]?.setSelected()
        }
        
        collectionTags.reloadData()
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
    
    
    // MARK: - Delegate Methods for the "Quick Category" buttons
    
    func changeLocation(location: String) {
        if location == "" {
            self.location = ""
            self.locationButton.setTitle("Choose a Location", for: .normal)
        }else{
            self.location = location
            self.locationButton.setTitle(location, for: .normal)
        }
    }
    
    // clear location button
    @IBAction func clearLocation(_ sender: Any) {
        changeLocation(location: "")
    }
    
    //MARK: - Helper functions
    @IBAction func changeLocation(_ sender: Any) {
        performSegue(withIdentifier: "filterLocation", sender: self)
    }
    
    // dismiss keyboard when touched outside of it
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    // set global filter state right before view disappears
    override func viewWillDisappear(_ animated: Bool) {
        globalFilterState = CurrentFilters(sort: sortField.text!,
                                           location: location,
                                           tags: Array(searchTags),
                                           categories: Array(categoriesSelected))
                
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "filterLocation",
           let changeLocationVC = segue.destination as? LocationViewController {
            changeLocationVC.delegate = self
            print("Filter Location")

        }
    }

}

