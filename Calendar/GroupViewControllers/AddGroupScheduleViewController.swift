//
//  AddGroupScheduleViewController.swift
//  Calendar
//
//  Created by yujeong on 2021/02/12.
//


import UIKit
import FSCalendar
import FirebaseDatabase
import Combine
import SwiftUI
import Firebase

class AddGroupScheduleViewController: UIViewController ,UITextFieldDelegate {
    var cancellable: AnyCancellable?
    var dDay : Bool = false
    var ref = Database.database().reference()
    var ref2 :  DatabaseReference!
    var keyid : String!
    @IBOutlet weak var uiview: UIView!
    var date : String!
    var time : Date!
    var uicolor : String!
    var color : UIColor!
    var color2 : String!
    var user : User!
    var selD : Date!
    @IBOutlet weak var uiView: UIView!
    
    // + 날짜 선택시 picker 닫아주기 구현해야함
    var schedule = Array<NSDictionary>()
    var groupId : String!
    
    var startDate : NSString!
    var startDay : NSString!
    var startPick : Date!
    var endDate : NSString!

    @IBOutlet weak var titleField: UITextField!
        
    @IBOutlet weak var dDaySwitch: UISwitch!
    
//    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var colorBtn: UIButton!
    @IBOutlet weak var startPicker: UIDatePicker!
    
    @IBOutlet weak var endPicker: UIDatePicker!
    
    @IBOutlet weak var memo: UITextField!
    
    let dateFormatter = DateFormatter()
    
    let timeFormatter : DateFormatter = DateFormatter();
    
    @IBOutlet weak var saveBtn: UIButton!
    var ts : String!


    @IBAction func dDaybtn(_ sender: Any) {
                if dDaySwitch.isOn == true{
                    dDay = true
                }else {dDay = false}
    }
    
    @objc func keyboardWillShow(_ sender: Notification) {
         self.view.frame.origin.y = -400 // Move view 150 points upward
        }
    @objc func keyboardWillHide(_ sender: Notification) {
    self.view.frame.origin.y = 0 // Move view to original position
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        uiView.layer.cornerRadius = 30
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        timeFormatter.dateFormat = "yyyy-MM-dd"
        colorBtn.layer.cornerRadius = colorBtn.frame.size.width / 2 // 원모양
        
        self.reloadInputViews()
        
 
        // db 읽어오는 곳
        if keyid != nil {
            if let date_nonoptional = date {
            let testQuery = ref.child("DB").child("users").child(groupId!).child("schedule").child(date_nonoptional).child(keyid!)
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
                var dBtn = "\(self.schedule[0].object(forKey: "d-Day")!)"
                if dBtn == "1" {
                    self.dDaySwitch.isOn == true
                    self.dDaySwitch.isOn = (self.schedule[0].object(forKey: "d-Day") != nil)
                    
                }
                            
            }
        }
        }
        
        
    }
    
 
    override func viewWillAppear(_ animated: Bool) {
        if selD != nil
        {
            startPicker.date = selD
            endPicker.date = selD
        startDay = timeFormatter.string(from: selD) as NSString
        startDate = dateFormatter.string(from: selD) as NSString
        }

    }
    // 시작 날짜
    @IBAction func changeStartDay(_ sender: UIDatePicker) {
        dateFormatter.dateFormat =  "yyyy-MM-dd HH:mm:ss ZZZ"
        endPicker.date = startPicker.date
        endPicker.minimumDate = startPicker.date
        startPick = startPicker.date
        startDate = dateFormatter.string(from: startPick) as NSString
        timeFormatter.dateFormat = "yyyy-MM-dd"
        startDay = timeFormatter.string(from: startPick) as NSString

    }
    
    // 종료 날짜
    @IBAction func changeEndDay(_ sender: Any) {
        dateFormatter.dateFormat =  "yyyy-MM-dd HH:mm:ss ZZZ"
        endDate = dateFormatter.string(from: endPicker.date) as NSString

    }
    
    
    // exit
    @IBAction func doExit(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
        
    }

    
    // Presenting the Color Picker
    @IBAction func changeColor(_ sender: Any) {
        
        let picker = UIColorPickerViewController()
        picker.selectedColor = colorBtn.backgroundColor!
        
        //  Subscribing selectedColor property changes.
        self.cancellable = picker.publisher(for: \.selectedColor)
            .sink { color in
                
                //  Changing view color on main thread.
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
        if keyid == nil {

            self.ref.child("DB").child("users").child("\(groupId!)").child("schedule").child("\(startDay!)").childByAutoId().setValue(["title": titleField.text, "startDate" : startDate, "endDate" : endDate ?? startDate ,"color" : uicolor ?? "\(UIColor.white)!", "memo" : memo.text ?? "",  "d-Day" : dDay, "date" : "\(startDay!)"
            ]){
                (error:Error?, ref:DatabaseReference) in
                if let error = error {
                  print("Data could not be saved: \(error).")
                } else {
            self.presentingViewController?.dismiss(animated: true, completion: nil)
                }
            }
        }
        

//        guard let key != ref.child(keyid).key else {return}
        else{
            self.ref.child("DB").child("users").child(groupId!).child("schedule").child(date).child(keyid).setValue(["title": titleField.text, "startDate" : startDate, "endDate" : endDate ?? startDate ,"color" : uicolor ?? "\(UIColor.white)!", "memo" : memo.text ?? "", "d-Day" : dDay, "date" : date
            ])
            
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }
    

}
