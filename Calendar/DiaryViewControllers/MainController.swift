//
//  MainController.swift
//  diary
//
//  Created by 다곰 on 2021/02/06.
//

import UIKit
import FirebaseDatabase
import Firebase

class MainController:UIViewController {
    var user : User!
    
    var ref: DatabaseReference!
    var ref2: DatabaseReference!
    
    var dateArr:[String] = []   //날짜 받아오기
    var dairy =  Array<NSDictionary>()  //사진, 일기 받아오기
    
    //선택한 셀
    var selectRow:Int?
    var selectDate:String?  //선택한 날짜
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        user = Auth.auth().currentUser
        ref = Database.database().reference()
        
        setupFlowLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
        self.collectionView.reloadData()
    }
    
    //DB에서 dairy 배열로 데이터 가져오기
    func loadData() {
        dateArr = []
        dairy = []
        
        ref2 = ref.child("DB").child("users").child("\(user.displayName!)").child("dairy")
        
        //날짜 불러오기
        ref2.observeSingleEvent(of: .value, with: { [self] (snapshot) in
            
            if let values = snapshot.value as? NSDictionary {
                for key in (values.allKeys) {
                    
                    self.dateArr.append(key as! String)
                    
                    self.collectionView.reloadData()
                }
            }
            
            
            //일기 불러오기
            ref2.observeSingleEvent(of: .value, with: { [self] (snapshot) in
                
                if let values = snapshot.value as? NSDictionary {
                    for key in (values.allKeys) {
                        let dairyData = values[key] as! NSDictionary
                        
                        self.dairy.append(dairyData)
                        
                    }
                    
                }
                
                self.collectionView.reloadData()
                
            })
            
        })
        
    }
    
    
    @IBAction func reloadBtn(_ sender: UIButton) {
        loadData()
        self.collectionView.reloadData()
    }

    private func setupFlowLayout() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets(top: 30, left: 30, bottom: 30, right: 30)
        flowLayout.minimumInteritemSpacing = 30
        flowLayout.minimumLineSpacing = 30
        
        let halfWidth = UIScreen.main.bounds.width / 3
        flowLayout.itemSize = CGSize(width: halfWidth , height: halfWidth)
        self.collectionView.collectionViewLayout = flowLayout
    }
    
    
}


//컬렉션 뷰에 셀 추가
extension MainController:UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dairy.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! Cell
        
        let row = indexPath.row
        
        
        
        //셀에 사진 붙이기
        let url = URL(string: "\(dairy[row].object(forKey: "pic") as! String)")
        
        do {
            let data = try Data(contentsOf: url!)
            cell.imageView.image = UIImage(data: data)
        }
        catch {}
        
        cell.dairyLabel.text = "\(dateArr[row])" //셀에 날짜 붙이기
        
        //        }
        return cell
    }
}

extension MainController:UICollectionViewDelegate {
    //클릭한 셀 처리
    //    prepar
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectRow = indexPath.row
        
        guard let vc = self.storyboard?.instantiateViewController(identifier: "EditController") as? EditController  else{
            return
        }
        vc.receivedRow = selectRow
        vc.receivedDate = dateArr[selectRow!] as? String
        
        self.present(vc, animated: true)

        
    }
    
    
}

//간격 조정
extension DiaryViewController:UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    
    //    셀 크기 조정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width-60) / 3
        let height = width * 1.5
        let size = CGSize(width: width, height: height)
        return size
    }
}

