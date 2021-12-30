//
//  SearchGroupViewController.swift
//  Calendar
//
//  Created by yujeong on 2021/02/07.
//

import UIKit
import FirebaseDatabase
import Firebase
class SearchGroupViewController:UIViewController {
    @IBOutlet weak var table: UITableView!
    var user : User!
    var groupName:String!
    var ref: DatabaseReference!
    var ref2 : DatabaseReference!
    var ref3 : DatabaseReference!
    var groups : [String] = []
    var participant : [String] = []
    var groupCheck : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        user = Auth.auth().currentUser
        ref = Database.database().reference()
        ref2 = ref.child("DB").child("users").child("\(user.displayName!)").child("groups")
        
        ref2.observeSingleEvent(of: .value, with: { (snapshot) in
            if let values = snapshot.value as? [String] {
                self.groups = values
            }
        })
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addGroup(_ sender: Any) {
        
        let addGroupAlert = UIAlertController(title: "그룹 추가", message: "그룹을 추가하시겠습니까?", preferredStyle: .alert)
        
        
        addGroupAlert.addAction(UIAlertAction(title: "그룹 추가", style: .default, handler: {[self] (action) in
            self.groups.append(self.groupName)
            self.ref2.setValue(self.groups)
            self.ref3 = self.ref.child("DB").child("users").child(self.groupName).child("participant")
            self.ref3.observeSingleEvent(of: .value) { [self](snapshot) in
                
                if let values = snapshot.value as? [String] {
                    self.participant = values
                    
                }
                
                self.participant.append("\(self.user.displayName!)")
                
                self.ref3.setValue(self.participant)
                
            }
            
            
        }))
        addGroupAlert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        self.present(addGroupAlert, animated: true, completion: nil)
        
    }
    
    
    
}

extension SearchGroupViewController:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchGroupCell", for: indexPath) as! SearchGroupCell
        
        ref3 = ref.child("DB").child("users")
        
        ref3.observeSingleEvent(of: .value, with: { [self](snapshot) in
            if let values = snapshot.value as? NSDictionary {
                for key in (values.allKeys) {
                    self.groupCheck.append(key as! String)
                }
            }
            
            for i in 0...groupCheck.count-1 {
                if groupCheck[i] == groupName! {
                    cell.searchGroupName.text = self.groupName
                    
                }
            }
            
            if cell.searchGroupName.text != groupName! {
                cell.groupAddBtn.isHidden = true
                cell.searchGroupName.text = "검색 결과가 없습니다."
            }
            
        })
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0;//Choose your custom row height
    }
}
