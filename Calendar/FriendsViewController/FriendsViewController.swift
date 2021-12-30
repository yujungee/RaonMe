//
//  FriendsViewController.swift
//  Calendar
//
//  Created by yujeong on 2021/02/05.
//
import UIKit
import FSCalendar
import FirebaseDatabase
import Firebase

class FriendsViewController : UIViewController {
    var ref : DatabaseReference!
    var ref2 : DatabaseReference!
    var ref3 : DatabaseReference!

    var user : User!
    var myFriends : [String] = []
    @IBOutlet weak var table: UITableView!
    var friendId : String!
    @IBOutlet weak var searchField: UISearchBar!
    
    @IBOutlet weak var searchBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        user = Auth.auth().currentUser
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadDate()
        searchField.text = ""
    }
    
    func loadDate() {
        ref = Database.database().reference()
        ref2 = ref.child("DB").child("users").child("\(user.displayName!)").child("friends")
        ref2.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let values = snapshot.value as? [String] {
                self.myFriends = values
            }
            self.table.reloadData()
        })
    }
 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let searchViewController = segue.destination as? SearchViewController
        {searchViewController.name = searchField.text}
        
        if let friendsViewController = segue.destination as? FriendsCalendarViewController
        {   let selectedPath = table.indexPathForSelectedRow
            friendsViewController.id = myFriends[(selectedPath?.row)!]
        }
        
    }
    
    @IBAction func search(_ sender: Any) {
        performSegue(withIdentifier: "searchName", sender: nil)
    }
}


extension FriendsViewController :UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return myFriends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendsCell", for: indexPath) as! FriendsCell
        let row = indexPath.row
//        loadDate()
        cell.friendName.text = myFriends[row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0;//Choose your custom row height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
//                friendId = myFriends[row]
        performSegue(withIdentifier: "goFriend", sender: nil)
    }
    
    // 셀 오른쪽 버튼
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let btnDelete = UIContextualAction(style: .destructive, title: "Del") {(action, view, completion) in
            
            let addAlert = UIAlertController(title: "친구 삭제", message: "친구를 삭제하시겠습니까?", preferredStyle: .alert)
            addAlert.addAction(UIAlertAction(title: "친구 삭제", style: .default, handler: { (action) in
                let row = indexPath.row
                self.ref3 = self.ref2.child("\(row)")
                self.ref3.removeValue()
                self.myFriends.remove(at: row)
                tableView.reloadData()
            }))
            addAlert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
            
            self.present(addAlert, animated: true, completion: nil)

            completion(true)
        }
        
        return UISwipeActionsConfiguration(actions: [btnDelete])
    }
}
