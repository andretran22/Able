//
//  PostCell.swift
//  AbleHomePage
//
//  Created by Tim Nguyen on 10/20/20.
//

import UIKit

class PostCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameButton: UIButton!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var postStatsLabel: UILabel!
//    @IBOutlet weak var postImageView: UIImageView!
    
    var post: Post! {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        usernameButton.setTitle("\(post.authorName)", for: .normal)
        locationLabel.text = post.location
        timeAgoLabel.text = post.createdAt.calenderTimeSinceNow()
        captionLabel.text = post.text
//        postStatsLabel.text = "\(post.numberOfComments!)"
    //        profileImageView.image = post.createdBy.profileImage
    //        usernameLabel.text = post.createdBy.username
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
    }
}
