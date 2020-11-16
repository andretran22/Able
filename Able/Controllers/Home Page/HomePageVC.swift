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

let DEFAULT_COLOR_TAGS = [UIColor(red: 0/255, green: 203/255, blue: 255/255, alpha: 1.0),   /* #00cbff, blue */
                          UIColor(red: 152/255, green: 145/255, blue: 255/255, alpha: 1.0), /* #9891ff, purple */
                          UIColor(red: 96/255, green: 255/255, blue: 149/255, alpha: 1.0),  /* #60ff95, green */
                          UIColor(red: 255/255, green: 186/255, blue: 246/255, alpha: 1.0), /* #ffbaf6, pink */
                          UIColor(red: 76/255, green: 255/255, blue: 147/255, alpha: 1.0),  /* #4cff93, mint */
                          UIColor(red: 255/255, green: 250/255, blue: 112/255, alpha: 1.0), /* #fffa70, yellow */
                          UIColor(red: 255/255, green: 130/255, blue: 150/255, alpha: 1.0), /* #ff8296, red */
                          UIColor(red: 255/255, green: 166/255, blue: 84/255, alpha: 1.0),  /* #ffa654, orange */
                          UIColor(red: 109/255, green: 242/255, blue: 255/255, alpha: 1.0)  /* #6df2ff, cyan */
                        ]

class HomePageVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate{
    
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
        
        // create global filter state with default sort by Most Recent
        globalFilterState = CurrentFilters(sort: "Most Recent", location: "", tags: [], categories: [])
        
        setView(view: helpFeedContainer, hidden: false)
        setView(view: helperFeedContainer, hidden: true)
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
        cell?.backgroundColor = cell?.backgroundColor!.adjust(by: -30)
    }

    // change background color back when user releases touch
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = self.tagColors[indexPath.row]
    }
    
}

