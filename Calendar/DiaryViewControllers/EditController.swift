//
//  EditController.swift
//  diary
//
//  Created by 다곰 on 2021/02/07.
//

import UIKit
import FirebaseDatabase
import Firebase

class EditController:UIViewController, SendDelegate {
    var user : User!
    var delegate:SendDelegate?
    
    var ref: DatabaseReference!
    var ref2: DatabaseReference!
    
    var dairy =  Array<NSDictionary>()
    
    var receivedDate:String?
    var receivedRow:Int?
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var dairyArea: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        user = Auth.auth().currentUser
        let storage = Storage.storage()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if receivedRow == nil {
        }
        else {
            
            ref = Database.database().reference()
            loadData()
            
        }
    }
    
    func loadData() {
        dairy = []
        
        ref2 = ref.child("DB").child("users").child("\(user.displayName!)").child("dairy")
        
        //날짜 불러오기
        ref2.observeSingleEvent(of: .value, with: { [self] (snapshot) in
            
            if let values = snapshot.value as? NSDictionary {
                for key in (values.allKeys) {
                    let dairyData = values[key] as! NSDictionary
                    self.dairy.append(dairyData)
                            
                }
                
            }
            
            let url = URL(string: "\(dairy[receivedRow!].object(forKey: "pic") as! String)")
            do {
                let data = try Data(contentsOf: url!)
                imageView.image = UIImage(data: data)
            }
            catch {}
            
            dairyArea.text = "\(dairy[receivedRow!].object(forKey: "text") as! String)" //셀에 날짜 붙이기
            
        })
        
    }
    
    //VC에서 받아온 데이터 붙이기
    func VCToEdit(dairy: String, photo: UIImage) {
        dairyArea.text = dairy
        imageView.image = photo
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //VC에서 받아올 데이터
        if segue.identifier == "editToVC" {
            let viewController:DiaryViewController = segue.destination as! DiaryViewController
            
            viewController.delegate = self
            
        }
        
        //VC로 보내기
        if let VC = segue.destination as? DiaryViewController {
            
            VC.vcDate = receivedDate!
            VC.vcRow = receivedRow!
            
        }
    }
    
    @IBAction func backBtn(_ sender: UIBarButtonItem) {
        guard let mainVC = self.storyboard?.instantiateViewController(identifier: "DiaryMain") as? MainController  else{
            return
        }
        mainVC.collectionView?.reloadData()
        // self.present(mainVC, animated: true)
        
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func deleteBtn(_ sender: UIButton) {
        dairyArea.text = nil
        imageView.image = nil
        ref2 = ref.child("DB").child("users").child("\(user.displayName!)").child("dairy").child(receivedDate!)
        ref2.removeValue()
        dismiss(animated: true, completion: nil)
        
    }
    
}
