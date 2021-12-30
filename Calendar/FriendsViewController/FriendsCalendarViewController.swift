//
//  FriendsCalendarViewController.swift
//  Calendar
//
//  Created by yujeong on 2021/02/05.
//

import UIKit
import FSCalendar
import FirebaseDatabase

class FriendsCalendarViewController : UIViewController {
    var selectedDate:String!
    let dateFormatter = DateFormatter()
    var selectDate:String!
    var ref : DatabaseReference!
    var ref2 : DatabaseReference!
    var id : String!
    var schedule = Array<NSDictionary>()
    
    @IBOutlet weak var friendNameLabel: UILabel!
    @IBOutlet weak var friendCalendar: FSCalendar!
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        friendCalendar.appearance.headerDateFormat = "YYYY년 M월"
        friendCalendar.locale = Locale(identifier: "ko_KR")
        friendNameLabel.text = id
        
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadDate()

    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? FriendsScheduleViewController {
            vc.date = selectDate
            vc.id = id
        }
    }
    
    
    func loadDate() {
        ref = Database.database().reference()
        if id != nil {
            
            ref2 = ref.child("DB").child("users").child(id!).child("schedule")
            ref2.observeSingleEvent(of: .value, with: { (snapshot) in
                if let testDict = snapshot.value as? NSDictionary {
                    // key
                    for key in (testDict.allKeys) {
                        let msgData = testDict[key] as! NSDictionary
                        //                    self.s2.append(key as! String)
                        for key2 in (msgData.allKeys){
                            let msg2 = msgData[key2] as! NSDictionary
                            self.schedule.append(msg2)
                            
                        }
                        
                    }
                    
                    self.friendCalendar.reloadData()
                }
                
            })
            
        }        
    }
    
    
    
    
    
}

extension FriendsCalendarViewController : FSCalendarDelegate, FSCalendarDataSource {
    
    
    
    // 날짜 선택 시 콜백 메소드
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition)  {
        selectDate = dateFormatter.string(from: date)
        print(dateFormatter.string(from: date) + " 선택됨")
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        performSegue(withIdentifier: "viewCalendar", sender: self)
        
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
//
