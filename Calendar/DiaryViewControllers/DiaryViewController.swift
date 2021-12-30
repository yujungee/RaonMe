//
//  ViewController.swift
//  diary
//
//  Created by 다곰 on 2021/01/31.
//

import UIKit
import FirebaseStorage
import Photos
import FirebaseDatabase
import Firebase

protocol SendDelegate {
    func VCToEdit(dairy:String, photo:UIImage)
}

class DiaryViewController: UIViewController {
    let storage = Storage.storage()
    var storageRef:StorageReference!
    var imagePicker:UIImagePickerController!
    var file_name:String!
    var delegate: SendDelegate?
    var sendImage:UIImage?
    var selectedDate:String?
    var picUrl:String?
    
    var ref: DatabaseReference!
    var ref2: DatabaseReference!
    
    var user : User!
    
    var vcDate:String?
  
   var dairy =  Array<NSDictionary>()

    var vcRow:Int?
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var textArea: UITextView!
    
    @IBOutlet weak var selectDate: UIDatePicker!
    override func viewDidLoad() {
        super.viewDidLoad()
        user = Auth.auth().currentUser  // 현재 사용자
        storageRef = storage.reference()
        ref = Database.database().reference()
        
        //edit mode에서는 날짜 선택 불가(데이트피커 숨기기)
        if let preVC = self.presentingViewController as? EditController {
            self.selectDate.isHidden = true
            self.loadData()
        }
    }
    

    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func loadData() {
        dairy = []  // 다이어리 받을 배열

        ref2 = ref.child("DB").child("users").child("\(user.displayName!)").child("dairy")
            
         //일기 불러오기
        ref2.observeSingleEvent(of: .value, with: { [self] (snapshot) in

                if let values = snapshot.value as? NSDictionary {
                    for key in (values.allKeys) {
                        let dairyData = values[key] as! NSDictionary
                        self.dairy.append(dairyData)
                    }
                }

            
            let url = URL(string: "\(dairy[vcRow!].object(forKey: "pic") as! String)")
                    do {
                        let data = try Data(contentsOf: url!)
                        imageView.image = UIImage(data: data)
                    }
                    catch {}
            
                    textArea.text = "\(dairy[vcRow!].object(forKey: "text") as! String)" //셀에 날짜 붙이기
            
            })
       
    }
    
    

    
    //다이어리에 쓸 이미지 선택
    @IBAction func selectImage(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        print("올릴 사진 선택하기")
        //취소 버튼 추가
        let action_cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(action_cancel)
        
        //갤러리 버튼 추가
        let action_gallery = UIAlertAction(title: "Gallery", style: .default) { (action) in
            print("push gallery button")
            switch PHPhotoLibrary.authorizationStatus() {
            case .authorized:
                print("접근가능")
                self.showGallery()
     
            case .notDetermined:
                print("권한 요청한 적 없음")
                PHPhotoLibrary.requestAuthorization(for: .readWrite) {(status) in
                    switch status {
                    case .authorized:
                        
                        print("허용함")
                    default:
                        print("허용 안했음")
                       
                    }
                }
            default:
                let alertVC = UIAlertController(title: "권한 필요", message: "사진첩 접근 권한이 필요합니다. 설정 화면에서 설정해주세요.", preferredStyle: .alert)
                let action_settings = UIAlertAction(title: "Go Settings", style: .default) {(action) in}
                
                if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
                }
                
                let action_cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alertVC.addAction(action_settings)
                alertVC.addAction(action_cancel)
                self.present(alertVC, animated: true, completion: nil)
                print("권한이 없어요. 추가해주세요")
            }
        
        }
        actionSheet.addAction(action_gallery)
        
        present(actionSheet, animated: true, completion: nil)
    }
    
   //데이트 피커
    @IBAction func selectDate(_ sender: UIDatePicker) {
        let datePickerView = sender
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
    }
    
    //저장버튼
    @IBAction func uploadBtn(_ sender: UIButton) {
        guard let image = imageView.image else {
            print("일기 저장")
            let alertVC = UIAlertController(title: "알림", message: "이미지를 선택하고 업로드 기능을 실행하세요.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertVC.addAction(okAction)
            self.present(alertVC, animated: true, completion: nil)
            return
        }
        
       if let data = image.pngData() {

            let imgRef = storageRef.child("image/\(file_name).png")
       
            let metadata = StorageMetadata()
            metadata.contentType = "image/png"
            let uploadTask = imgRef.putData(data,metadata: metadata){(metadata,error) in
                if let error = error {
                    return
                }
        
              imgRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                  return
                }

                
                if self.vcDate == nil {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    self.vcDate = formatter.string(from: self.selectDate.date as Date)

                }
                //DB에 일기 추가
                    self.ref.child("DB").child("users").child("\(self.user.displayName!)").child("dairy").child("\(self.vcDate!)").setValue(["text": "\(self.textArea.text!)", "pic":"\(url!)"])
   
              }
            }
        }
        
        if let data = textArea?.text {
            if let photo = sendImage {
            delegate?.VCToEdit(dairy: data, photo: sendImage!)
            print(photo,"보냄")
    
            }
        }
        
        if let preVC = self.presentingViewController as? MainController {
            print("추가 완료")
            preVC.loadData()
            preVC.collectionView.reloadData()
            preVC.dismiss(animated: true, completion: nil)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    //키보드 내리기
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension DiaryViewController:UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func showGallery() {
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[.originalImage] as? UIImage else {
            return
        }
        
        if let url = info[.imageURL] as? URL{
            file_name = (url.lastPathComponent as NSString).deletingPathExtension
        }
        imageView.image = selectedImage
        
        //uiImage인 selectede image를 다른 controlelr로 전달
        //editVC로 전달(역으로 전달)
        sendImage = imageView.image
        //upload버튼 누르면 보내는 게 best긴 한데 일단은,,
        //로딩처리
        if let data = textArea!.text {
            delegate?.VCToEdit(dairy: data, photo: sendImage!)
        }
        
    }
}

