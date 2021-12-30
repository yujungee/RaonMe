//
//  FriendsScheduleViewController.swift
//  Calendar
//
//  Created by yujeong on 2021/02/07.
//

import UIKit
import Firebase
import FSCalendar
class FriendsScheduleViewController:UIViewController {
    var ref : DatabaseReference!
    var ref2 : DatabaseReference!
    var schedule = Array<NSDictionary>()
    var date : String!
    var schedule2 = Array<NSDictionary>()
    var user : User!
    var id :String!
    @IBOutlet weak var fTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        loadData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    func loadData() {
        user = Auth.auth().currentUser
        ref = Database.database().reference()
        ref2 = ref.child("DB").child("users").child(id!).child("schedule").child(date) // user 대신 친구 아이디
        ref2.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let values = snapshot.value as? NSDictionary {
                for key in (values.allKeys) {
                    let msgData = values[key] as! NSDictionary
                    self.schedule.append(msgData)
                }
                self.fTable.reloadData()
            }
        })
    
    }
}

extension FriendsScheduleViewController:UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0;//Choose your custom row height
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schedule.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendScheduleCell", for: indexPath) as! FriendScheduleCell
        let row = indexPath.row

        
        if ((schedule[row].object(forKey: "locking")) as! String == "true") {
            cell.titleLable.text = "비공개 일정"
        }
        else{
        cell.titleLable.text = "\(schedule[row].object(forKey: "title")!)"
        }
        
        
        var color2 = schedule[row].object(forKey: "color") as! String
        let color = UIColor(hexaDecimalString: "#\(color2)FF")
        cell.colorImageView.backgroundColor = color
        
        let a = schedule[row].object(forKey: "startDate") as! String
        var firstIndex = a.index(a.startIndex, offsetBy: 0)
        var lastIndex = a.index(a.startIndex, offsetBy: 18)
        let mobCom = "\(a[firstIndex..<lastIndex])"
        cell.startDate.text = mobCom
        

        if "\(schedule[row].object(forKey: "startDate"))" != "\(schedule[row].object(forKey: "endDate"))" as! String {
            let b = schedule[row].object(forKey: "endDate") as! String
             firstIndex = b.index(a.startIndex, offsetBy: 0)
            lastIndex = b.index(a.startIndex, offsetBy: 18)
            let mobCom = "\(b[firstIndex..<lastIndex])"
            cell.barLabel.text = " - "
            cell.endDate.text = mobCom
        }
        return cell
    }
    
    
}
