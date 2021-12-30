//
//  ViewController.swift
//  calendar
//
//  Created by 다곰 on 2021/01/28.
//

import UIKit
import FSCalendar
import FirebaseDatabase
import Firebase

class ToDoViewController: UIViewController, FSCalendarDelegate {
    var user : User!
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var tableView: UITableView!
    
    //날짜 가져오기
    let dateFormatter = DateFormatter()
    var dateString:String?
    
    //선택한 셀 열값, 텍스트
    var selectRow:Int?
    var selectText:String?
    
    

    //받아온 color text
    var checkColor:String?
    //체크박스 체크 여부 확인 flag
    var doCheck:Int?
    
    //수정받은 텍스트
    var receivedText:String?

    
    var cellId:[String] = []
    var todo =  Array<NSDictionary>()

   var ref: DatabaseReference!
   var ref2:DatabaseReference!
   
    //화면 띄우기
    override func viewDidLoad() {
        super.viewDidLoad()
        user = Auth.auth().currentUser
        //dateString 오늘 날짜
        let date = NSDate()
        let formatter = DateFormatter() // DateFormatter 클래스 상수 선언
        formatter.dateFormat = "yyyy-MM-dd"
        dateString = formatter.string(from: date as Date)
   
        //week단위로 달력 보기
        calendar.delegate = self
        calendar.scope = .week
        calendar.setScope(.week, animated: false)
        
        calendar.appearance.headerDateFormat = "YYYY년 M월"
        
        calendar.locale = Locale(identifier: "ko_KR")

        // 요일
        calendar.calendarWeekdayView.weekdayLabels[0].text = "일"
        calendar.calendarWeekdayView.weekdayLabels[1].text = "월"
        calendar.calendarWeekdayView.weekdayLabels[2].text = "화"
        calendar.calendarWeekdayView.weekdayLabels[3].text = "수"
        calendar.calendarWeekdayView.weekdayLabels[4].text = "목"
        calendar.calendarWeekdayView.weekdayLabels[5].text = "금"
        calendar.calendarWeekdayView.weekdayLabels[6].text = "토"

       
        ref = Database.database().reference()
     
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addData()
        self.tableView.reloadData()
    }
 
    func addData() {
        cellId = []     // 셀 아이디를 받을 배열
        todo = []   // todo 내용 받을 배열

    ref2 = ref.child("DB").child("users").child("\(user.displayName!)").child("ToDo").child(dateString!)
    ref2.observeSingleEvent(of: .value, with: { [self] (snapshot) in

            if let values = snapshot.value as? NSDictionary {
                for key in (values.allKeys) {
                    let msgData = values[key] as! NSDictionary
                    self.cellId.append(key as! String)
                    self.todo.append(msgData)
                   
                        self.tableView.reloadData()
                }
            }
        })
    }
    
    // 삭제
    func deleteData(row:Int) {
        ref2 = ref.child("DB").child("users").child("\(user.displayName!)").child("ToDo").child(dateString!).child("\(cellId[row])")
        ref2.removeValue()
        
    }


    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateString = dateFormatter.string(from: date)
        addData()
        self.tableView.reloadData()
    }


    //체크박스 클릭했을 경우
    @IBAction func checkBox(_ sender: UIButton) {
        let btnRow = sender.tag
        sender.isSelected = !sender.isSelected
        var check:Int = 0
        if sender.isSelected {
            if todo[btnRow].object(forKey: "check") as! Int == 0 {
                check = 1
            }
        }
        if todo[btnRow].object(forKey: "color") != nil {
            checkColor = todo[btnRow].object(forKey: "color") as! String
        } else{
            checkColor = "\(UIColor.white)"
        }
        
        
    ref2 = ref.child("DB").child("users").child("\(user.displayName!)").child("ToDo").child(dateString!)
    ref2.observeSingleEvent(of: .value, with: { [self] (snapshot) in

            if let values = snapshot.value as? NSDictionary {
                for key in (values.allKeys) {
                
                   //***저장한 정보 없으면 오류남
                    guard let key = self.ref2.child("\(self.cellId[btnRow])").key else {return}
                    
                    let db = ["todo": "\(todo[btnRow].object(forKey: "todo") as! String)", "color" : checkColor,"check" : check] as [String : Any]
                    let childUpdates = ["/\(key)":db]
                    self.ref2.updateChildValues(childUpdates)
                
                }
            }
        })
       
    }
    
    //***셀 길게 클릭하면 이동바 나타남
    @IBAction func changeOrder(_ sender: UILongPressGestureRecognizer) {
        self.tableView.isEditing.toggle()
    }

    //prepare
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //일정 등록(add로 보낼 데이터)
        if let addVC = segue.destination as? memoController
        {addVC.receivedDate = dateString}
    }

}

//테이블뷰에 셀 추가
extension ToDoViewController:UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "memoCell", for: indexPath) as! memoCell
        let row = indexPath.row
        cell.memoLabel?.text = "\(todo[row].object(forKey: "todo") as! String)"
        
        if todo[row].object(forKey: "color") != nil {
            var color2 = todo[row].object(forKey: "color") as! String
            checkColor = color2
            let color = UIColor(hexaDecimalString: "#\(color2)FF")
            cell.checkBtn.tintColor = color
        }
        else {
            let color = UIColor.white
            cell.checkBtn.tintColor = color
        }
        
        cell.checkBtn.tag = row
        
        if todo[cell.checkBtn.tag].object(forKey: "check") as! Int == 1 {
            cell.checkBtn.isSelected = true
        }
        else {
            cell.checkBtn.isSelected = false
        }
        return cell
    }
    
   
    
    //스와이프 방지
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

extension ToDoViewController:UITableViewDelegate {
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none    //왼쪽에 이모지 없음
    }
    
    //스와이프하면 오른쪽에 취소버튼 추가
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        //삭제 버튼
        let btnDelete = UIContextualAction(style: .destructive, title: "Del"){ (action, view, completion) in
        
            let row = indexPath.row
            self.deleteData(row: row)
            self.todo.remove(at: row)
           // self.dataSource.remove(at: row)
            
            //tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()
        
            completion(true)
        }
        
        //버튼 색상 지정
        btnDelete.backgroundColor = .black
        return UISwipeActionsConfiguration(actions: [btnDelete])
    }
    
    //클릭한 셀 처리
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //클릭한 셀 row값
        selectRow = indexPath.row
        selectText = "\(todo[selectRow!].object(forKey: "todo") as! String)"

        guard let editVC = self.storyboard?.instantiateViewController(identifier: "editCont") as? editController  else{
            return
        }
        editVC.editTitle = selectText
        editVC.receivedDate = dateString
        editVC.receivedID = cellId[selectRow!] as! String
        if todo[selectRow!].object(forKey: "color") != nil {
            editVC.receivedColor = todo[selectRow!].object(forKey: "color") as! String
        } else {
            editVC.receivedColor = "\(UIColor.white)"
        }
        
        
        self.present(editVC, animated: true)
        
        //selct 풀기
        tableView.deselectRow(at: indexPath, animated: false)
        
    }
    
    //자간 조정
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableView.frame.height / 12
    }
}

