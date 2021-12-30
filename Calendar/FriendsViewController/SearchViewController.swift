//
//  SearchViewController.swift
//  Calendar
//
//  Created by yujeong on 2021/02/05.
//


import UIKit
import FirebaseDatabase
import Firebase
class SearchViewController : UIViewController {
    var name : String!
    @IBOutlet weak var table: UITableView!
    var ref: DatabaseReference!
    var ref2 : DatabaseReference!
    var friends : [String] = []
    var user : User!
    var ref3 : DatabaseReference!
    var test : [String] = []
    
    override func viewDidLoad() {
        user = Auth.auth().currentUser
        super.viewDidLoad()
        ref = Database.database().reference()
        ref2 = ref.child("DB").child("users").child("\(user.displayName!)").child("friends")
        ref2.observeSingleEvent(of: .value, with: { (snapshot) in
            if let values = snapshot.value as? [String] {
                self.friends = values
                }
    })
        table.separatorStyle = UITableViewCell.SeparatorStyle.none
        
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    
    @IBAction func addFriend(_ sender: Any) {
        let addAlert = UIAlertController(title: "친구 추가", message: "친구를 추가하시겠습니까?", preferredStyle: .alert)
        addAlert.addAction(UIAlertAction(title: "친구추가", style: .default, handler: { (action) in
            self.friends.append(self.name)
            self.ref2 = self.ref.child("DB").child("users").child("\(self.user.displayName!)").child("friends")
            self.ref2.setValue(self.friends)
        }))
        addAlert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        
        self.present(addAlert, animated: true, completion: nil)
    
    }
}

extension SearchViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "search", for: indexPath) as! searchCell

        ref2 = ref.child("DB").child("users")
                //        loadData()
                        ref2.observeSingleEvent(of: .value, with: { [self](snapshot) in
                            if let values = snapshot.value as? NSDictionary {
                                for key in (values.allKeys) {
                                    self.test.append(key as! String)
                                }
                                }
                            
                            for i in 0...test.count-1 {
                                      if test[i] == name! {
                                          cell.searchLabel.text = self.name
                                        
                                      }
                                
                                      
                                  }
                            
                            if cell.searchLabel.text != name! {
                                cell.addFriendBtn.isHidden = true
                                cell.searchLabel.text = "검색 결과가 없습니다."
                            }
                 
                    })
        return cell

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0;//Choose your custom row height
    }
}
