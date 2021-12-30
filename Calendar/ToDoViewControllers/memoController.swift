//
//  createMemoCell.swift
//  calendar
//
//  Created by 다곰 on 2021/01/30.
//

import UIKit
import Firebase
import Combine

class memoController:UIViewController{
 
     //db연결 reference
    var ref: DatabaseReference!
    var refHandle:DatabaseHandle!
    var ref2:DatabaseReference!
    
    var cancellable:AnyCancellable?

    var receivedDate: String?
    var uicolor:String?
      
    var user : User!
    
    
    @IBOutlet weak var todoTitle: UITextField!
    
    @IBOutlet weak var exitBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var colorBtn: UIButton!
    @IBOutlet weak var categoryBtn: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var plusBtn: UIButton!
    @IBOutlet weak var uiview: UIView!
    @IBOutlet weak var addBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uiview.layer.cornerRadius = 30  // 뷰 모서리 둥글게
        ref = Database.database().reference()
        user = Auth.auth().currentUser  // 현재 사용자 불러오기
        
        // 키보드 처리
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dateLabel.text = receivedDate
    }
   

    // 컬러 버튼
    @IBAction func colorBtn(_ sender: Any) {
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
    
    
  //x버튼 동작
    @IBAction func goBack(_ sender: UIButton) {
            dismiss(animated: true, completion: nil)
    }
    
    //체크 버튼 동작
    @IBAction func saveAction(_ sender: UIButton) {
        //DB에 todo 업데이트
        self.ref.child("DB").child("users").child("\(self.user.displayName!)").child("ToDo").child("\(receivedDate!)").childByAutoId().setValue(["todo": "\(todoTitle.text!)", "color" : uicolor ?? "\(UIColor.white)!" ,"check" : 0])
        
        //저장하기
        if let preVC = self.presentingViewController as? ToDoViewController {
            preVC.addData()
            preVC.tableView.reloadData()
            dismiss(animated: true, completion: nil)

        }
        dismiss(animated: true, completion: nil)
    }

    @objc func keyboardWillShow(_ sender: Notification) {
         self.view.frame.origin.y = -400 // Move view 150 points upward
        }
    @objc func keyboardWillHide(_ sender: Notification) {
    self.view.frame.origin.y = 0 // Move view to original position
    }
    
}
