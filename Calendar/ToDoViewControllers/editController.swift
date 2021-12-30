//
//  editController.swift
//  calendar
//
//  Created by 다곰 on 2021/01/30.
//

import UIKit
import Combine
import FirebaseDatabase
import Firebase


//일정텍스트를 viewController로 전달하기 위한 프로토콜

class editController:UIViewController, UITextFieldDelegate {
  
    var user : User!
    
    @IBOutlet weak var editView: UIView!
    var ref: DatabaseReference!
    var ref2:DatabaseReference!
    
    var editTitle: String?  //수정하려는 일정 이름
    var receivedColor:String?
    
    var receivedDate:String?    //수정하고 있는 todo가 저장된 날짜
    var editRow: Int?   //수정하고 있는 cell row
    
    var receivedID:String?
    var todo =  Array<NSDictionary>()
    
    /*칼라피커 관련*/
    var cancellable:AnyCancellable?
    var editColor:String?
    
    @IBOutlet weak var todoTitle: UITextField!
    @IBOutlet weak var exitBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var colorBtn: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editView.layer.cornerRadius = 30     // 뷰 모서리 둥글게
        ref = Database.database().reference()  // reference
        user = Auth.auth().currentUser  // 현재 사용자
        todoTitle.text = editTitle  //수정할 일정 이름 받아옴
        let cColor = UIColor(hexaDecimalString: "#\(receivedColor!)FF") // 색깔 받아옴
        colorBtn.backgroundColor = cColor   // 받아온 색 넣어주기
        
        // 키보드 처리
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dateLabel.text = receivedDate   //받아온 날짜 붙여넣기
        todoTitle.text = editTitle  //받아온 일정 이름 field에 붙여넣기
    }
    
    // 수정하는 함수
    func editData() {
        ref2 = ref.child("DB").child("users").child("\(user.displayName!)").child("ToDo").child(receivedDate!)
        ref2.observeSingleEvent(of: .value, with: { [self] (snapshot) in

                if let values = snapshot.value as? NSDictionary {
                    for key in (values.allKeys) {
                       // let msgData = values[key] as! NSDictionary                        
                       //***저장한 정보 없으면 오류남
                        guard let key = self.ref2.child("\(receivedID!)").key else {return}
                        
                        let db = ["todo": "\(todoTitle.text!)", "color" : editColor ?? "\(receivedColor!)","check" : 0] as [String : Any]
                        let childUpdates = ["/\(key)":db]
                        self.ref2.updateChildValues(childUpdates)
                    }
                }
            })
        }

    
    //칼라버튼 --> ui컬러픽커 사용
    @IBAction func colorEdit(_ sender: Any) {
        let picker = UIColorPickerViewController()
        picker.selectedColor = colorBtn.backgroundColor ?? UIColor.white
            
       self.cancellable = picker.publisher(for: \.selectedColor)
           .sink { color in
               DispatchQueue.main.async {
                   self.colorBtn.backgroundColor = color
         
                self.editColor = color.toHexString()
               }
           }
           self.present(picker, animated: true, completion: nil)

    }
    
    //X버튼
    @IBAction func goBack(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    //check 버튼
    @IBAction func saveAction(_ sender: UIButton) {
        editData()
        
        dismiss(animated: true, completion: nil)
    }
    
    //키보드 바깥쪽 화면 누르면 키보드 없어짐
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // 키보드 처리
    @objc func keyboardWillShow(_ sender: Notification) {
         self.view.frame.origin.y = -400 // Move view 150 points upward
        }
    @objc func keyboardWillHide(_ sender: Notification) {
    self.view.frame.origin.y = 0 // Move view to original position

    }
    
}
