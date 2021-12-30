//
//  subTitleCell.swift
//  Calendar
//
//  Created by yujeong on 2021/02/09.
//

import UIKit
import FSCalendar

class subTitleCell: FSCalendarCell {

    let lbSecondaRiga = UILabel(frame: CGRect(x: 0, y: 15, width: 20, height: 10))

    required init!(coder aDecoder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        let lbSecondaRiga = UILabel(frame: CGRect(x: 0, y: 15, width: 20, height: 10))
            lbSecondaRiga.textAlignment = .left
            lbSecondaRiga.lineBreakMode = .byWordWrapping
            lbSecondaRiga.textColor = self.subtitleLabel.textColor
            lbSecondaRiga.text = ""
//            self.lbSecondaRiga = lbSecondaRiga
            
            
            let view = UIView(frame: self.bounds)
            view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.12)
            view.insertSubview(self.lbSecondaRiga, belowSubview: self.subtitleLabel)
            self.backgroundView = view;

    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        self.lbSecondaRiga.frame = self.subtitleLabel.frame
        self.lbSecondaRiga.font = self.subtitleLabel.font
        self.lbSecondaRiga.textAlignment = self.subtitleLabel.textAlignment
        self.lbSecondaRiga.lineBreakMode = self.subtitleLabel.lineBreakMode
        self.lbSecondaRiga.textColor = self.subtitleLabel.textColor
        
        self.lbSecondaRiga.frame.origin.y += 10
        }
    }




