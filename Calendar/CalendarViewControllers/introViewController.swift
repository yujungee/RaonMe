//
//  introViewController.swift
//  Calendar
//
//  Created by yujeong on 2021/02/10.
//

import UIKit
import LTMorphingLabel



    
   

class introViewController: UIViewController ,LTMorphingLabelDelegate{


    @IBOutlet weak var label: LTMorphingLabel!
    
    // 로고 꾸미기
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    
        label.text = "LaOnMe"
        label.delegate = self
        label.morphingEnabled = true
        label.morphingDuration = 3.0
        
        
        label.morphingEffect = .anvil
               

    }


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        let timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { (timer) in
            if let vc = self.storyboard?.instantiateViewController(identifier: "firstTabViewController") {
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: false, completion: nil)
            }
        }
       
    }
}


extension introViewController {
    
    func morphingDidStart(_ label: LTMorphingLabel) {
        
    }
    
    func morphingDidComplete(_ label: LTMorphingLabel) {
        
    }
    
    func morphingOnProgress(_ label: LTMorphingLabel, progress: Float) {
        
    }
    
}
