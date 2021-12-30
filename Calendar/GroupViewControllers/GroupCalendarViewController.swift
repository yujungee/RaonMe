//
//  GroupCalendarViewController.swift
//  Calendar
//
//  Created by yujeong on 2021/02/07.
//

import UIKit
import FirebaseDatabase
import Firebase
import FSCalendar

class GroupCalendarViewController:UIViewController {
    var ref = Database.database().reference()
    var ref2 :  DatabaseReference!
   var ref3 : DatabaseReference!
    var groupName : String!
    @IBOutlet weak var infoTable: UITableView!
    var selectDate : String!
    let dateFormatter = DateFormatter()
    @IBOutlet weak var calendar: FSCalendar!
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    var selD : Date!
    var schedule = Array<NSDictionary>()
    var participant : [String] = []
    override func viewDidLoad() {
        calendar.delegate = self
        calendar.dataSource = self
        super.viewDidLoad()
        
        calendar.allowsMultipleSelection = true //여러날짜를 동시에 선택할 수 있도록
        calendar.swipeToChooseGesture.isEnabled = true // 다중 스와이프로 선택
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        
        calendar.appearance.headerDateFormat = "YYYY년 M월"
        
        // 달력의 요일 글자 바꾸는 방법 1
        calendar.locale = Locale(identifier: "ko_KR")
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadDate()

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? GroupListViewController {
            vc.date = selectDate
            vc.groupId = groupName
            vc.selD = selD
        }
    }

    func loadDate(){
        
        ref = Database.database().reference()
        ref2 = ref.child("DB").child("users").child(groupName!)
        
        ref2.child("schedule").observeSingleEvent(of: .value, with: { (snapshot) in
            if let testDict = snapshot.value as? NSDictionary {
                // key
                for key in (testDict.allKeys) {
                    let msgData = testDict[key] as! NSDictionary
                    for key in (msgData.allKeys){
                        let msg2 = msgData[key] as! NSDictionary
                        self.schedule.append(msg2)
                    }
                }
                self.calendar.reloadData()
            }
            
        })
        
        ref3 = ref2.child("participant")
        ref3.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let values = snapshot.value as? [String] {
                self.participant = values
                self.infoTable.reloadData()
                }
            self.infoTable.reloadData()

    })
        self.infoTable.reloadData()
        
        }


}



extension GroupCalendarViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return participant.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          let cell = tableView.dequeueReusableCell(withIdentifier: "participant", for: indexPath) as! ParticipantCell
        let row = indexPath.row
        cell.participantName.text = participant[row]
        return cell
    }


}


extension GroupCalendarViewController : FSCalendarDelegate, FSCalendarDataSource {

    // 날짜 선택 시 콜백 메소드
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition)  {
        selectDate = dateFormatter.string(from: date)
        selD = date
        print(dateFormatter.string(from: date as Date) + " 선택됨")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        performSegue(withIdentifier: "groupSchedule", sender: self)
        
    }
    // 날짜 선택 해제 시 콜백 메소드
    public func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print(dateFormatter.string(from: date) + " 해제됨")
        
    }

    

    func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {
        var titles = [String]()
        var title = String()
        
        if schedule.count != 0 {
            print(schedule, "scheduleing")
            for i in 0...(schedule.count - 1) {
                if dateFormatter.string(from: date) == schedule[i].object(forKey: "date") as! String {
                    titles.append(schedule[i].object(forKey: "title") as! String)
                    if ((schedule[i].object(forKey: "d-Day") as! Bool ) == true) {return "D-day"}
                }
            }
           if titles.count > 0 {
           var scheduleCount = "+\(titles.count)"
            return scheduleCount
            }
            }

        
        return nil
    
}
}



