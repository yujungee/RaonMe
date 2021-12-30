//
//  extensions.swift
//  Calendar
//
//  Created by yujeong on 2021/02/14.
//

import UIKit

extension UIColor {


//Convert RGBA String to UIColor object
//"rgbaString" must be separated by space "0.5 0.6 0.7 1.0" 50% of Red 60% of Green 70% of Blue Alpha 100%
public convenience init?(rgbaString : String){
    self.init(ciColor: CIColor(string: rgbaString))
}

//Convert UIColor to RGBA String
func toRGBAString()-> String {

    var r: CGFloat = 0
    var g: CGFloat = 0
    var b: CGFloat = 0
    var a: CGFloat = 0
    self.getRed(&r, green: &g, blue: &b, alpha: &a)
    return "\(r) \(g) \(b) \(a)"

}
    
//return UIColor from Hexadecimal Color string
public convenience init?(hexaDecimalString: String) {

        let r, g, b, a: CGFloat

        if hexaDecimalString.hasPrefix("#") {
            
            let start = hexaDecimalString.index(hexaDecimalString.startIndex, offsetBy: 1)
            let hexColor = hexaDecimalString.substring(from: start)
            
            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
// Convert UIColor to Hexadecimal String
func toHexString() -> String {
    var r: CGFloat = 0
    var g: CGFloat = 0
    var b: CGFloat = 0
    var a: CGFloat = 0
    self.getRed(&r, green: &g, blue: &b, alpha: &a)
    return String(
        format: "%02X%02X%02X",
        Int(r * 0xff),
        Int(g * 0xff),
        Int(b * 0xff)
    )
}
}


