//
//  ViewController.swift
//  Calendar
//
//  Created by yujeong on 2021/01/28.
//

import UIKit
import FSCalendar
import FirebaseDatabase
import Firebase
import FirebaseUI


class ViewController: UIViewController, FSCalendarDelegateAppearance, FUIAuthDelegate {
    var selD : Date!
    let authUI = FUIAuth.defaultAuthUI()
    var handle:AuthStateDidChangeListenerHandle!
    @IBOutlet weak var btnSignOut: UIBarButtonItem!
    var selectedIndex:Int = 0
    var previousIndex:Int = 0
    var userId : String!
    var user : User!
    var titles : [String]!
    @IBOutlet weak var btnStackView: UIStackView!
    //    var viewControllers = [UIViewController]()
    @IBOutlet weak var idLabel: UILabel!
    var selectDate:String!
    
    var ref : DatabaseReference!
    var ref2 : DatabaseReference!
    var schedule = Array<NSDictionary>()
    var s2 =  Array<String>()
    let dateFormatter = DateFormatter()
    
    @IBOutlet var tabBtns: [UIImageView]!
    @IBOutlet weak var calendar: FSCalendar!
    
    
    // 하단 메뉴 바 뷰 연결할 거
    var viewControllers = [UIViewController]()
    static let firstTabViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "firstTabViewController")
    
    static let secondTabViewController = UIStoryboard(name: "ToDoList", bundle: nil).instantiateViewController(identifier: "todo")
    
    static let thirdTabViewController = UIStoryboard(name: "Diary", bundle: nil).instantiateViewController(identifier: "DiaryMain")
    
    static let forthTabViewController = UIStoryboard(name: "Friends", bundle: nil).instantiateViewController(identifier: "friendsView")
    
    static let fifthTabViewController = UIStoryboard(name: "Group", bundle: nil).instantiateViewController(identifier: "groupViewController")
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 하단 메뉴바 버튼, 뷰 추가
        for btn in tabBtns {
            btn.contentMode = .scaleAspectFit
            btn.layer.transform = CATransform3DMakeScale(0.8, 0.8, 0.8)
            let tap = UITapGestureRecognizer(target: self, action: #selector(tabTapped(_:)))
            
            btn.isUserInteractionEnabled = true
            btn.addGestureRecognizer(tap)
        }
        
        // viewController 연결
        viewControllers.append(ViewController.firstTabViewController)
        viewControllers.append(ViewController.secondTabViewController)
        viewControllers.append(ViewController.thirdTabViewController)
        viewControllers.append(ViewController.forthTabViewController)
        viewControllers.append(ViewController.fifthTabViewController)
        
        // 캘린더 & 날짜
        calendar.delegate = self
        calendar.dataSource = self
        calendar.appearance.headerMinimumDissolvedAlpha = 0.6
        dateFormatter.dateFormat = "yyyy-MM-dd"
        calendar.appearance.headerDateFormat = "YYYY년 M월"
        calendar.locale = Locale(identifier: "ko_KR")
 
    } // viewDidLoad
 
    

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    
    // 로그인이 안되어 있으면 무조건 로그인 창 켜라
    // 로그 아웃 기능 실행 후에 로그인 창을 띄워라
    // 한쪽에 앱을 키고 다른쪽에 로그인을 해라 --> 다른쪽 로그아웃됨
    // 상태가 바뀌는걸 감시하는 감시자가 필요
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let currentUser = auth.currentUser {
                // 로그인 되어있는 상태
                self.user = Auth.auth().currentUser
                self.loadDate()
                if let displayName = currentUser.displayName {
                    self.idLabel.text = displayName
                }
                

            }else {
                // 로그아웃 되어있는 상태
                self.authUI!.delegate = self
                let providers: [FUIAuthProvider] = [
                    FUIEmailAuth(),
                    FUIGoogleAuth()
                ]
                self.authUI!.providers = providers
                let authViewController = self.authUI!.authViewController()
                authViewController.modalPresentationStyle = .fullScreen
                self.present(authViewController, animated: true, completion: nil)

            }
        }

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // 로그인 확인
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        print("sign in")
        print(authDataResult)
        
    }
    
    // 로그아웃
    @IBAction func doSignOut(_ sender: Any) {
        let result = try? authUI?.signOut()
    }
    
    // 데이터 불러오기
    func loadDate() {
        ref = Database.database().reference()

        ref2 = ref.child("DB").child("users").child("\(user.displayName!)").child("schedule")
        ref2.observeSingleEvent(of: .value, with: { (snapshot) in
            if let testDict = snapshot.value as? NSDictionary {
                // key
                for key in (testDict.allKeys) {
                    let msgData = testDict[key] as! NSDictionary
                    self.s2.append(key as! String)
                    for key2 in (msgData.allKeys){
                        let msg2 = msgData[key2] as! NSDictionary
                        self.schedule.append(msg2)
                    }
                }
            }
            self.calendar.reloadData()
        })
    }
    

    
    @objc func tabTapped(_ sender:UITapGestureRecognizer){
        print("tapped")
        if let tag = sender.view?.tag {
            previousIndex = selectedIndex
            selectedIndex = tag

            // 화면 갈이끼기
            let previousVC = viewControllers[previousIndex]
            previousVC.willMove(toParent: nil)
            previousVC.view.removeFromSuperview()
            previousVC.removeFromParent()

            let currentVC = viewControllers[selectedIndex]
            currentVC.view.frame = UIApplication.shared.windows[0].frame
            currentVC.didMove(toParent: self)
            self.addChild(currentVC)
            self.view.addSubview(currentVC.view)
            self.view.bringSubviewToFront(btnStackView)
        }
    }

 
    
}


extension ViewController : FSCalendarDelegate, FSCalendarDataSource {
    
    // 날짜 선택 시 콜백 메소드
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition)  {
        selD = date
        selectDate = dateFormatter.string(from: date)
        print(dateFormatter.string(from: date) + " 선택됨")
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        performSegue(withIdentifier: "listview", sender: self)

    }
    // 날짜 선택 해제 시 콜백 메소드
    public func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print(dateFormatter.string(from: date) + " 해제됨")
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ListViewController {
            vc.date = selectDate
            vc.selD = selD
        }
    }


    // 캘린더 subtitle 설정
    func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {
        titles = [String]()
        if schedule.count != 0 {

            for i in 0...(schedule.count - 1) {
                if dateFormatter.string(from: date) == schedule[i].object(forKey: "date") as! String {
                    titles.append(schedule[i].object(forKey: "title") as! String)
                    if ((schedule[i].object(forKey: "d-Day") as! Bool ) == true) {return "D-day"}
                }
            }
            
           if titles.count > 0 {
            return "click"
                }
            }
        return nil  // 아무 이벤트 없음
    
    }
}

// fscalendar
extension FSCalendar : FSCalendarDelegateAppearance{
    func customizeCalenderAppearance() {
        self.appearance.caseOptions = [.headerUsesUpperCase,.weekdayUsesSingleUpperCase]
        self.appearance.subtitleOffset = CGPoint(x: 0, y:5)
        self.appearance.headerMinimumDissolvedAlpha = 0.0 // Hide Left Right Month Name
    }
}


extension FUIAuthBaseViewController {
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.leftBarButtonItems = nil
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }
}



