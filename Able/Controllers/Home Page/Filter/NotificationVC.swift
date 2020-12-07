//
//  NotificationVC.swift
//  Able
//
//  Created by Andre Tran on 12/6/20.
//

import UIKit
import Firebase

class NotificationCell: UITableViewCell {
    
    @IBOutlet weak var commenterImage: UIImageView!
    @IBOutlet weak var commenterName: UILabel!
    @IBOutlet weak var timeAgo: UILabel!
    @IBOutlet weak var comment: UILabel!
    
    var notification: NotificationObj! {
        didSet{
            updateUI()
        }
    }
    
    func updateUI() {
        commenterName.text = notification.fullname
        timeAgo.text = notification.timestamp?.calenderTimeSinceNow()
        comment.text = "\"\(notification.text!)\""
        ImageService.downloadImage(withURL: URL(string: notification.pictureUrl!)!) { image in
            self.commenterImage.image = image
        }
        
    }
    
    // when pressed segues to post. Post id/key can be accessed using notification.postId
    @IBAction func goToPostButton(_ sender: Any) {
    }
    
}

class NotificationVC:  UIViewController,UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var notificationTableView: UITableView!
    @IBOutlet weak var sortButtonLabel: UIButton!
    var fetchedNotifications = [NotificationObj]()
    var sortState:String?

    override func viewDidLoad() {
        super.viewDidLoad()
        notificationTableView.delegate = self
        notificationTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.sortState = "Most Recent"
        self.fetchNotifications()
    }
    
    // MARK:- Sort Functions
    
    @IBAction func sortButton(_ sender: Any) {
        // toggle state
        if sortState == "Most Recent" {
            sortState = "Oldest First"
        }else{
            sortState = "Most Recent"
        }
        
        sortNotifications()
    }
    
    func sortNotifications(){        
        if self.sortState == "Most Recent" {
            print("ELLOOO")
            fetchedNotifications = fetchedNotifications.sorted(by: { $0.timestamp! > $1.timestamp! })
        }else{
            fetchedNotifications = fetchedNotifications.sorted(by: { $0.timestamp! < $1.timestamp! })
        }
        self.sortButtonLabel.setTitle(self.sortState, for: .normal)
        self.notificationTableView.reloadData()
    }
    
    // MARK:- Table View Functions
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedNotifications.count
    }
    
    /// animation to deselectrow
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        notificationTableView.deselectRow(at: indexPath, animated: true)
    }
    
    /// custom cell for table view
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = notificationTableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath as IndexPath) as! NotificationCell
        
        let row = indexPath.row
        cell.notification = fetchedNotifications[row]
        return cell
    }
    
    // MARK:- Fetch Notifications
    
    /// fetch all notifications from current user through firebase
    func fetchNotifications(){
        let notificationRef = Database
            .database()
            .reference()
            .child("users")
            .child(publicCurrentUser!.safeEmail)
            .child("notifications")
        
        notificationRef.observeSingleEvent(of: .value) { snapshot in
            
            var tempNotifications = [NotificationObj]()
            
            for notification in snapshot.children {
                if let notificationSnap = notification as? DataSnapshot,
                   let notificationData = notificationSnap.value as? [String: Any],
                   let commenterKey = notificationData["commenterKey"] as? String,
                   let fullname = notificationData["fullname"] as? String,
                   let pictureUrl = notificationData["pictureUrl"] as? String,
                   let postId = notificationData["postId"] as? String,
                   let timestamp = notificationData["timestamp"] as? Double,
                   let text = notificationData["text"] as? String,
                   let type = notificationData["type"] as? String
                   {
                    
                    let notif = NotificationObj(commenterKey: commenterKey,
                                                fullname: fullname,
                                                pictureUrl: pictureUrl,
                                                postId: postId,
                                                timestamp: timestamp,
                                                text: text,
                                                type: type)
                    notif.printInfo()
                    tempNotifications.append(notif)
                }
            }
            self.fetchedNotifications = tempNotifications
            self.sortNotifications()
            self.notificationTableView.reloadData()
        }
    }

}
