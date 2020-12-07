//
//  notificationCell.swift
//  Able
//
//  Created by Andre Tran on 12/6/20.
//

import UIKit

class NotificationCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate,
                        UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var commenterImage: UIImageView!
    @IBOutlet weak var commenterName: UILabel!
    @IBOutlet weak var timeAgo: UILabel!
    @IBOutlet weak var comment: UILabel!
        
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        <#code#>
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        <#code#>
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        <#code#>
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath)
        
        let row = indexPath.row
        
        cell.textLabel?.text = options[row]
        return cell
        
    }
    
}

