//
//  HomePageVC.swift
//  Able
//
//  Created by Tim Nguyen on 10/14/20.
//

import UIKit

class TagCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var tagLabel: UILabel!
}

let DEFAULT_TAGS = ["Food", "Water", "Clothes", "Toiletries", "Medicine", "Toys",
                    "Furniture", "Tech", "Other"]

let DEFAULT_COLOR_TAGS = [UIColor.systemBlue, UIColor.systemPurple, UIColor.systemGreen, UIColor.systemPink, UIColor.green, UIColor.systemYellow, UIColor.systemOrange, UIColor.blue, UIColor.magenta]

class HomePageVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var helpFeedContainer: UIView!
    @IBOutlet weak var helperFeedContainer: UIView!
    @IBOutlet weak var collectionViewTags: UICollectionView!
    
    let tagIdentifier = "TagCellIdentifier"
    var tags = DEFAULT_TAGS
    var tagColors = DEFAULT_COLOR_TAGS
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionViewTags.delegate = self
        collectionViewTags.dataSource = self
    
        // create global user for reference once signed up or logged in
        DatabaseManager.shared.setPublicUser()
    }
    
    @IBAction func switchViews(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            setView(view: helpFeedContainer, hidden: false)
            setView(view: helperFeedContainer, hidden: true)
        }
        else{
            setView(view: helpFeedContainer, hidden: true)
            setView(view: helperFeedContainer, hidden: false)
        }
    }
    
    // animation helper function to hide/show views
    func setView(view: UIView, hidden: Bool) {
        UIView.transition(with: view, duration: 0.3, options: .transitionCrossDissolve, animations: {
            view.isHidden = hidden
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: tagIdentifier, for: indexPath as IndexPath) as! TagCollectionViewCell
        
        let row = indexPath.row
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        cell.tagLabel.text = self.tags[row] // The row value is the same as the index of the desired text within the array.
        cell.backgroundColor = self.tagColors[row] // make cell more visible in our example project
        cell.layer.cornerRadius = 8
        return cell
    }
    
    // change background color when user touches cell
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor.red
    }

    // change background color back when user releases touch
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = self.tagColors[indexPath.row]
    }
}

