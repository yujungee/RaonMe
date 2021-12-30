//
//  GroupViewController.swift
//  Calendar
//
//  Created by yujeong on 2021/02/07.
//

import UIKit
import FirebaseDatabase
import Firebase
class GroupViewController:UIViewController {
    var ref = Database.database().reference()
    var ref2 :  DatabaseReference!
    var ref3 :  DatabaseReference!

    var groupName : String!
    @IBOutlet weak var table: UITableView!
    
    @IBOutlet weak var GroupField: UISearchBar!
    var groups : [String] = []

    @IBOutlet weak var addGroup: UIButton!
    
    var user : User!
    override func viewDidLoad() {
        user = Auth.auth().currentUser
        super.viewDidLoad()
        loadDate()

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadDate()
    }

    func loadDate() {
        user = Auth.auth().currentUser
        ref = Database.database().reference()
        ref2 = ref.child("DB").child("users").child("\(user.displayName!)").child("groups")
        ref2.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let values = snapshot.value as? [String] {
                self.groups = values
                self.table.reloadData()
                }
                self.table.reloadData()
                    
    })
        self.table.reloadData()
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let searchGroupController = segue.destination as? SearchGroupViewController
        {searchGroupController.groupName = GroupField.text}
        
        if let groupCalendarViewController = segue.destination as? GroupCalendarViewController {
            let selectedPath = table.indexPathForSelectedRow
            groupCalendarViewController.groupName = groups[(selectedPath?.row)!]
        }
        
    }
    
    @IBAction func searchGroup(_ sender: Any) {
        performSegue(withIdentifier: "searchGroup", sender: nil)
    }
    
    
    @IBAction func addGroup(_ sender: Any) {
        let addAlert = UIAlertController(title: "Add Group", message: "enter group name", preferredStyle: .alert)
        
        addAlert.addTextField { (textField) in
            textField.text = ""
        }
        addAlert.addAction(UIAlertAction(title: "add", style: .default, handler: { (action) in
            if let fields = addAlert.textFields, let textFields = fields.first, let text = textFields.text {
                self.ref.child("DB").child("users").child(text).setValue("\(text)")
                self.groups.append(text)
                self.ref2.setValue(self.groups)
                self.table.reloadData()
            }
        }))
        
        self.present(addAlert, animated: true, completion: nil)
    }

    
}


extension GroupViewController:UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCell", for: indexPath) as! GroupCell
        let row = indexPath.row
        cell.groupName.text = groups[row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0;//Choose your custom row height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        performSegue(withIdentifier: "goCalendar", sender: nil)
    }
    
    // 셀 오른쪽 버튼
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let btnDelete = UIContextualAction(style: .destructive, title: "Del") {(action, view, completion) in
            
            let addAlert = UIAlertController(title: "그룹 삭제", message: "그룹을 삭제하시겠습니까?", preferredStyle: .alert)
            addAlert.addAction(UIAlertAction(title: "그룹 삭제", style: .default, handler: { (action) in
                let row = indexPath.row
                self.ref3 = self.ref2.child("\(row)")
                self.ref3.removeValue()
                self.groups.remove(at: row)
                tableView.reloadData()
            }))
            addAlert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
            
            self.present(addAlert, animated: true, completion: nil)

            completion(true)
        }
        
        return UISwipeActionsConfiguration(actions: [btnDelete])
    }
    
}

