//
//  PostCell.swift
//  AbleHomePage
//
//  Created by Tim Nguyen on 10/20/20.
//

import UIKit

class PostCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameButton: UIButton!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var postStatsLabel: UILabel! // works for number of comments and ratings label
//    @IBOutlet weak var postImageView: UIImageView!
    
    // only for help or helper posts
    @IBOutlet weak var tagsCollectionView: UICollectionView?
    @IBOutlet weak var numberOfCommentsLabel: UILabel?
    
    // only for review posts
    @IBOutlet weak var ratingLabel: UILabel?
    
    var tags = [String]()
    
    var post: Post! {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        usernameButton.setTitle(post.authorName, for: .normal)
        locationLabel.text = post.location
        timeAgoLabel.text = post.createdAt.calenderTimeSinceNow()
        captionLabel.text = post.text
        
        // for help and helper posts
        if (post.tags != nil) {
            tags = post.tags!
            tagsCollectionView?.delegate = self
            tagsCollectionView?.dataSource = self
        }
        
        // for reviews
        if (post.rating != nil) {
            ratingLabel?.text =  String(Int(post.rating!))
        }
        
//        postStatsLabel.text = "\(post.numberOfComments!)"
    //        profileImageView.image = post.createdBy.profileImage
    //        usernameLabel.text = post.createdBy.username
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostTagsCollectionCell", for: indexPath as IndexPath) as! TagCollectionViewCell
        
        let row = indexPath.row
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        cell.tagLabel.text = self.tags[row] // The row value is the same as the index of the desired text within the array.
        cell.backgroundColor = DEFAULT_COLOR_TAGS[row % 9] // make cell more visible in our example project
        cell.layer.cornerRadius = 8
        return cell
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
    }
}
