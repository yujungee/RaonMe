//
//  addlistViewController.swift
//  Calendar
//
//  Created by yujeong on 2021/01/29.
//


import UIKit
import FSCalendar
import FirebaseDatabase
import Combine
import SwiftUI
import Firebase

class AddlistViewController: UIViewController {
    
    var cancellable: AnyCancellable?
    var  color : UIColor!
    var uicolor : String!
    var locking : String = "false"
    var dDay : Bool = false
    var ref = Database.database().reference()
    var ref2 :  DatabaseReference!
    var keyid : String!
    var date : String!
    var time : Date!
    var user : User!
    @IBOutlet weak var uiView: UIView!
    var selD : Date!
    // + 날짜 선택시 picker 닫아주기 구현해야함
    var schedule = Array<NSDictionary>()
    
    var startDate : NSString!
    var startDay : NSString!
    var startPick : Date!
    var endDate : NSString!
    var color2 : String!

    
    @IBOutlet weak var titleField: UITextField!
    
    @IBOutlet weak var lockSwitch: UISwitch!
    
    @IBOutlet weak var dDaySwitch: UISwitch!
    
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var colorBtn: UIButton!    
    @IBOutlet weak var startPicker: UIDatePicker!
    
    @IBOutlet weak var endPicker: UIDatePicker!
    
    @IBOutlet weak var memo: UITextField!
    
    let dateFormatter = DateFormatter()
    
    let timeFormatter : DateFormatter = DateFormatter();
    
    @IBOutlet weak var saveBtn: UIButton!
    var ts : String!


    
    override func viewDidLoad() {
        super.viewDidLoad()
        user = Auth.auth().currentUser  // 현재 사용자
        uiView.layer.cornerRadius = 30  // 모서리 둥글게
        colorBtn.layer.cornerRadius = colorBtn.frame.size.width / 2 // 원모양
        // dateFormat
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        timeFormatter.dateFormat = "yyyy-MM-dd"
        
        // 키보드 처리
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    
// 키보드 디데이
        if lockSwitch.isOn {
            locking = "true"
        }else {locking = "false"}

        if dDaySwitch.isOn {
            dDay = true
        }else {dDay = false}
             
        // db 읽어오는 곳
        if keyid != nil {
            if let date_nonoptional = date {
            timeFormatter.dateFormat = "yyyy-MM-dd"
            let testQuery = ref.child("DB").child("users").child("\(user.displayName!)").child("schedule").child(date_nonoptional).child(keyid!)
            testQuery.observe(.value) {(snapshot) in
                let testDict = snapshot.value as? NSDictionary ?? [:]
                self.schedule.append(testDict)
                self.titleField.text = "\(self.schedule[0].object(forKey: "title")!)"
                self.startDate = self.schedule[0].object(forKey: "startDate") as! NSString
                self.startPicker.date = self.dateFormatter.date(from: self.startDate as String)!
                self.endDate = self.schedule[0].object(forKey: "endDate") as! NSString
                self.endPicker.date = self.dateFormatter.date(from: self.endDate as String)!
                self.color2 = self.schedule[0].object(forKey: "color") as! String
                self.uicolor = self.color2
                self.color = UIColor(hexaDecimalString: "#\(self.color2!)FF")
                self.colorBtn.backgroundColor = self.color
                self.memo.text = "\(self.schedule[0].object(forKey: "memo")!)"
                
                if (self.schedule[0].object(forKey: "locking") as! String == "true" ){
                    self.lockSwitch.isOn = true
                }else { self.lockSwitch.isOn = false}
                
                
                var dBtn = "\(self.schedule[0].object(forKey: "d-Day")!)"
                if dBtn == "1" {
                    self.dDaySwitch.isOn == true
                    self.dDaySwitch.isOn = (self.schedule[0].object(forKey: "d-Day") != nil)
                    
                }
                
//                self.dDaySwitch.isOn = ((self.schedule[0].object(forKey: "d-Day")) != nil)
            }
        }
        }
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if selD != nil
        {startPicker.date = selD
            endPicker.date = selD
        startDay = timeFormatter.string(from: selD) as NSString
        startDate = dateFormatter.string(from: selD) as NSString
        }

    }
    
    // 시작 날짜
    @IBAction func changeStartDay(_ sender: UIDatePicker) {
        dateFormatter.dateFormat =  "yyyy-MM-dd HH:mm:ss ZZZ"
        endPicker.date = startPicker.date   // 종료는 시작보다 앞설 수 없다
        endPicker.minimumDate = startPicker.date
        startPick = startPicker.date
        startDate = dateFormatter.string(from: startPick) as NSString
        startDay = timeFormatter.string(from: startPick) as NSString

    }
    
    // 종료 날짜
    @IBAction func changeEndDay(_ sender: Any) {
        dateFormatter.dateFormat =  "yyyy-MM-dd HH:mm:ss ZZZ"
        endDate = dateFormatter.string(from: endPicker.date) as NSString
    }
    
    // locking
    @IBAction func doLock(_ sender: Any) {
        if lockSwitch.isOn {locking = "true"}
        else {locking = "false"}
    }
    
    // d-day
    @IBAction func doDday(_ sender: Any) {
        if dDaySwitch.isOn {dDay = true}
        else {dDay = false}
    }
    
    // exit
    @IBAction func doExit(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
        
    }

    
// 칼라 버튼 처리
    @IBAction func changeColor(_ sender: Any) {
        let picker = UIColorPickerViewController()
        picker.selectedColor = colorBtn.backgroundColor!
        self.cancellable = picker.publisher(for: \.selectedColor)
            .sink { color in
                DispatchQueue.main.async {
                    self.colorBtn.backgroundColor = color
                    self.uicolor = color.toHexString()
                }
            }
        self.present(picker, animated: true, completion: nil)
        
    }
    
    
    // 데이터 쓰기
    @IBAction func doSave(_ sender: Any) {
        timeFormatter.dateFormat = "yyyy-MM-dd"
        // 새로 추가
        if keyid == nil {
            self.ref.child("DB").child("users").child("\(user.displayName!)").child("schedule").child("\(startDay!)").childByAutoId().setValue(["title": titleField.text, "startDate" : startDate, "endDate" : endDate ?? startDate ,"color" : uicolor ?? "\(UIColor.white)!", "memo" : memo.text ?? "", "locking" : locking, "d-Day" : dDay, "date" : "\(startDay!)"
            ]){
                (error:Error?, ref:DatabaseReference) in
                if let error = error {
                  print("Data could not be saved: \(error).")
                } else {
            self.presentingViewController?.dismiss(animated: true, completion: nil)
                }
        }
        }
        
        // 업데이트
        else{
            self.ref.child("DB").child("users").child("\(user.displayName!)").child("schedule").child(date).child(keyid).setValue(["title": titleField.text, "startDate" : startDate, "endDate" : endDate ?? startDate ,"color" : uicolor ?? "\(UIColor.white)!", "memo" : memo.text ?? "", "locking" : locking, "d-Day" : dDay, "date" : "\(startDay!)"
            ])
            
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    
    // 키보드 처리
    @objc func keyboardWillShow(_ sender: Notification) {
         self.view.frame.origin.y = -400 // Move view 150 points upward
        }
    @objc func keyboardWillHide(_ sender: Notification) {
    self.view.frame.origin.y = 0 // Move view to original position
    }
}


