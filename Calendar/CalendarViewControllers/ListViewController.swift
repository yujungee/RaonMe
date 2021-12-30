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

class ListViewController: UIViewController {
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
    var keyString : String?
    var userId : String!
    var user : User!
    var selD : Date!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        user = Auth.auth().currentUser
        table.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        
        guard let pvc = self.presentingViewController else { return }
        self.dismiss(animated: true) {
            pvc.present(AddlistViewController(), animated: true, completion: nil)
        }
        
    } // viewDidLoad
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
        table.reloadData()
    }
    
    // 전달할 값 prepare
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let addlistViewController = segue.destination as? AddlistViewController{
            let selectedPath = table.indexPathForSelectedRow
            addlistViewController.keyid = cellId[(selectedPath?.row)!] as! String
            addlistViewController.date = date!
        }
    }
    
    // db 불러오기
    func loadData() {
        ref = Database.database().reference()
        ref2 = ref.child("DB").child("users").child("\(user.displayName!)").child("schedule").child(date)
        ref2.observeSingleEvent(of: .value, with: { (snapshot) in
            if let values = snapshot.value as? NSDictionary {
                for key in (values.allKeys) {
                    let msgData = values[key] as! NSDictionary
                    self.cellId.append(key)
                    self.schedule.append(msgData)
                }
                self.table.reloadData()
            }
            self.table.reloadData()
        })
    }
    
    
    // add 버튼 눌렀을 때
    @IBAction func showAdd(_ sender: Any) {
        guard let pvc = self.presentingViewController else { return }
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "addViewController") as! AddlistViewController
        self.dismiss(animated: false) {
            pvc.present(vc, animated: true, completion: nil)
            vc.selD = self.selD
        }
    }
    
    
    
} // class

extension ListViewController : UITableViewDataSource
{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0;
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schedule.count
    }
    
    // 셀 설정
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "info", for: indexPath) as! InfoCell
        let row = indexPath.row
        cell.titleLabel.text = schedule[row].object(forKey: "title") as! String
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
    
    // 클릭 시
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        let row = indexPath.row
        guard let pvc = self.presentingViewController else { return }
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "addViewController") as! AddlistViewController
        self.dismiss(animated: false) {
            vc.keyid = self.cellId[indexPath.row] as! String
            vc.date = self.date!
            vc.selD = self.selD
            pvc.present(vc, animated: true, completion: nil)
            
        }
    }
    
    
    
    // cell 오른쪽 끝에 나타날 버튼들
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let btnDelete = UIContextualAction(style: .destructive, title: "Del") {(action, view, completion) in
            let addAlert = UIAlertController(title: "일정 삭제", message: "일정을 삭제하시겠습니까?", preferredStyle: .alert)
            addAlert.addAction(UIAlertAction(title: "일정 삭제", style: .default, handler: { (action) in
                let row = indexPath.row
                self.ref = Database.database().reference()
                self.ref2 = self.ref.child("DB").child("users").child("\(self.user.displayName!)").child("schedule").child(self.date!).child("\(self.cellId[row])")
                self.ref2.removeValue()
                self.schedule.remove(at: row)
                tableView.reloadData()
            }))
            addAlert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
            tableView.reloadData()
            self.present(addAlert, animated: true, completion: nil)
            completion(true)
            
        }
        
        
        return UISwipeActionsConfiguration(actions: [btnDelete])
    }
    
    
    
}

extension ListViewController :UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
