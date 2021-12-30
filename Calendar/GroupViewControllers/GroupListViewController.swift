//
//  liistViewController.swift
//  Calendar
//
//  Created by yujeong on 2021/01/29.
//

import UIKit
import FSCalendar
import FirebaseDatabase
import Firebase

class GroupListViewController: UIViewController {
    @IBOutlet weak var table: UITableView!
    var date : String!
    var schedule = Array<NSDictionary>()
    var ref : DatabaseReference!
    var ref2 : DatabaseReference!
    var cellId = Array<Any>()
    let timeFormatter : DateFormatter = DateFormatter();
    var titleLabel : String!
    var dateLabel : String!
    var cellCount : Int!
//    var uicolor : UIColor!
    var keyString : String?
    var groupId : String!

    var selD : Date!
    override func viewDidLoad() {
        super.viewDidLoad()

        if groupId == nil {viewDidLoad()}
        
        table.separatorStyle = UITableViewCell.SeparatorStyle.none
        guard let pvc = self.presentingViewController else { return }
        self.dismiss(animated: true) {
            pvc.present(AddGroupScheduleViewController(), animated: true, completion: nil)
        }

        
        print(schedule.count, "dkdkdk")

        
    } // viewDidLoad
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()

    }
    
    func loadData() {
 
        ref = Database.database().reference()
        ref2 = ref.child("DB").child("users").child(groupId!).child("schedule").child(date!)
        ref2.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let values = snapshot.value as? NSDictionary {
                for key in (values.allKeys) {
                    let msgData = values[key] as! NSDictionary
                    self.cellId.append(key)
                    self.schedule.append(msgData)
                }
                self.table.reloadData()
            }
        })
        self.table.reloadData()
    }

        @IBAction func showAdd(_ sender: Any) {
            guard let pvc = self.presentingViewController else { return }
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "addGroupScheuleViewController") as! AddGroupScheduleViewController
            self.dismiss(animated: false) {
                pvc.present(vc, animated: true, completion: nil)
                vc.groupId = self.groupId
                vc.selD = self.selD
            }
            
        }

   
    
} // class

extension GroupListViewController : UITableViewDataSource
{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0;//Choose your custom row height
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schedule.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupInfoCell", for: indexPath) as! GroupInfoCell
        let row = indexPath.row
        cell.titleLabel.text = "\(schedule[row].object(forKey: "title")!)"
        let a = schedule[row].object(forKey: "startDate") as! String
        var firstIndex = a.index(a.startIndex, offsetBy: 0)
        var lastIndex = a.index(a.startIndex, offsetBy: 18)
        let mobCom = "\(a[firstIndex..<lastIndex])"
        cell.dateLabel.text = mobCom
        
        var color2 = schedule[row].object(forKey: "color") as! String
        let color = UIColor(hexaDecimalString: "#\(color2)FF")
        cell.colorView.backgroundColor = color
        
        if "\(schedule[row].object(forKey: "startDate"))" != "\(schedule[row].object(forKey: "endDate"))" as! String {
            let b = schedule[row].object(forKey: "endDate") as! String
             firstIndex = b.index(a.startIndex, offsetBy: 0)
            lastIndex = b.index(a.startIndex, offsetBy: 18)
            let mobCom = "\(b[firstIndex..<lastIndex])"
            cell.barLabel.text = " - "
            cell.endDateLabel.text = mobCom
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        guard let pvc = self.presentingViewController else { return }
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "addGroupScheuleViewController") as! AddGroupScheduleViewController
        self.dismiss(animated: false) {
            vc.keyid = self.cellId[indexPath.row] as! String
            vc.date = self.date!
            
            vc.groupId = self.groupId
            pvc.present(vc, animated: true, completion: nil)
            
        }
        
        
    }
//    

//    
    // cell 오른쪽 끝에 나타날 버튼들
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let btnDelete = UIContextualAction(style: .destructive, title: "Del") {(action, view, completion) in
            let row = indexPath.row
            self.ref = Database.database().reference()
            self.ref2 = self.ref.child("DB").child("users").child("\(self.groupId!)").child("schedule").child(self.date!).child("\(self.cellId[row])")
            self.ref2.removeValue()
            self.schedule.remove(at: row)
            self.table.reloadData()
            completion(true)
        }
        
        
        btnDelete.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [btnDelete])
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let btnEdit = UIContextualAction(style: .normal, title: "Edit") {(action, view, completion) in
        }
        btnEdit.backgroundColor = .blue
        return UISwipeActionsConfiguration(actions: [btnEdit])
    }
    
}

extension GroupListViewController :UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    
}


//
