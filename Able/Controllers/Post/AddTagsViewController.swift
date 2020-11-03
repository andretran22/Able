//
//  AddTagsViewController.swift
//  Able
//
//  Created by Tim Nguyen on 11/3/20.
//

import UIKit

class AddTagsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var yourTagsCollectionView: UICollectionView!
    @IBOutlet weak var defaultTagsCollectionView: UICollectionView!
    @IBOutlet weak var customTagTextField: UITextField!
    
    var delegate: UIViewController?
    var yourTags = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        yourTagsCollectionView.delegate = self
        yourTagsCollectionView.dataSource = self
        defaultTagsCollectionView.delegate = self
        defaultTagsCollectionView.dataSource = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (collectionView == yourTagsCollectionView) {
            return yourTags.count
        } else {
            return DEFAULT_TAGS.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (collectionView == yourTagsCollectionView) {
            let cell = yourTagsCollectionView.dequeueReusableCell(withReuseIdentifier: "YourTagCellIdentifier", for: indexPath as IndexPath) as! TagCollectionViewCell
            // get a reference to our storyboard cell
            let row = indexPath.row
            // Use the outlet in our custom class to get a reference to the UILabel in the cell
            cell.tagLabel.text = yourTags[row] // The row value is the same as the index of the desired text within the array.
            cell.backgroundColor = UIColor.systemBlue // make cell more visible in our example project
            cell.layer.cornerRadius = 8
            return cell
        } else {
            let cell = defaultTagsCollectionView.dequeueReusableCell(withReuseIdentifier: "DefaultTagCellIdentifier", for: indexPath as IndexPath) as! TagCollectionViewCell
            // get a reference to our storyboard cell
            let row = indexPath.row
            // Use the outlet in our custom class to get a reference to the UILabel in the cell
            cell.tagLabel.text = DEFAULT_TAGS[row] // The row value is the same as the index of the desired text within the array.
            cell.backgroundColor = DEFAULT_COLOR_TAGS[row] // make cell more visible in our example project
            cell.layer.cornerRadius = 8
            return cell
        }
    }
    
    // when the default tags are selected, they will be added into the user's used tags
    // when the your tags are selected, they will be removed
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let row = indexPath.row
        if (collectionView == defaultTagsCollectionView) {
            defaultTagsCollectionView.deselectItem(at: indexPath, animated: true)
            yourTags.append(DEFAULT_TAGS[row])
        } else {
            yourTagsCollectionView.deselectItem(at: indexPath, animated: true)
            yourTags.remove(at: row)
        }
        yourTagsCollectionView.reloadData()
    }
    
    // adds the custom tag into the user's used tags
    @IBAction func addCustomTagButtonClicked(_ sender: Any) {
        yourTags.append(customTagTextField.text!)
        yourTagsCollectionView.reloadData()
        print(yourTags)
    }
    
    // cancel and go back to the previous screen
    @IBAction func cancelButtonClicked(_ sender: Any) {
        dismissPopover()
    }
    
    // done and apply the tags to the create a post
    @IBAction func doneButtonClicked(_ sender: Any) {
        let createPostVC = delegate as! ApplyTags
        createPostVC.addTags(newTags: yourTags)
        dismissPopover()
    }
    
    func dismissPopover() {
        self.dismiss(animated: true, completion: nil)
    }
}
