//
//  Extentions.swift
//  Canto
//
//  Created by WhoTan on 11/14/17.
//  Copyright © 2017 WhoTan. All rights reserved.
//

import UIKit
import CoreMedia


extension UIView{
   
    func round(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    func asImage() -> UIImage? {
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(bounds: bounds)
            return renderer.image { rendererContext in
                layer.render(in: rendererContext.cgContext)
            }
        } else {
            UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0.0)
            defer { UIGraphicsEndImageContext() }
            guard let currentContext = UIGraphicsGetCurrentContext() else {
                return nil
            }
            self.layer.render(in: currentContext)
            return UIGraphicsGetImageFromCurrentImageContext()
        }
    }
    
    func headerViewCornerRounding(){
        self.backgroundColor = UIColor.white
//        self.layer.cornerRadius = 15
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOpacity = 0.7
        self.layer.shadowRadius = 5
//        self.layer.shadowOffset = CGSize(width: 0, height: 2)
    }
    
    func darkGradiantLayer(){
        
        let gradiantLayer = CAGradientLayer()
        let topColor = UIColor(red: 36/255, green: 37/255, blue: 41/255, alpha: 0).cgColor
        let bottomColor =  UIColor(red: 36/255, green: 37/255, blue: 41/255, alpha: 1).cgColor
        gradiantLayer.colors = [topColor, bottomColor]
        gradiantLayer.startPoint = CGPoint(x: 0.0, y: 0.3)
        gradiantLayer.endPoint = CGPoint(x: 0.0, y: 1.0)
        gradiantLayer.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        self.layer.insertSublayer(gradiantLayer, at: 0)
    }
    
    func doubleDarkGradiantLayer(){
        
        let gradiantLayer = CAGradientLayer()
        let bottomColor =  UIColor(red: 36/255, green: 37/255, blue: 41/255, alpha: 1).cgColor
        let topColor = UIColor(red: 36/255, green: 37/255, blue: 41/255, alpha: 0.0).cgColor
        gradiantLayer.colors = [topColor, bottomColor]
        gradiantLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradiantLayer.endPoint = CGPoint(x: 0.0, y: 1.0)
        gradiantLayer.frame = CGRect(x: 0, y: self.frame.height - 20, width: self.frame.width, height: 20)
        self.layer.insertSublayer(gradiantLayer, at: 0)
    }
    
    func roundAndShadow(){
        self.layer.cornerRadius = 10
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowRadius = 5
        self.layer.shadowOpacity = 0.7
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
    }
    
    func round(){
        self.layer.cornerRadius = self.frame.height/2
    }
    
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)]
        animation.duration = 0.6
        animation.values = [-20, 20, -10, 10, -5, 5, 0]
        self.layer.add(animation, forKey: "shake")
    }
    
    
}
extension String {
    func utf8DecodedString()-> String {
        let data = self.data(using: .utf16)
        if let message = String(data: data!, encoding: .nonLossyASCII){
            return message
        }
        return ""
    }
    
    func utf8EncodedString()-> String {
        let messageData = self.data(using: .nonLossyASCII)
        let text = String(data: messageData!, encoding: .utf8)
        return text!
    }
}
extension UIApplication {
    class func topViewController(viewController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = viewController as? UINavigationController {
            return topViewController(viewController: nav.visibleViewController)
        }
        if let tab = viewController as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(viewController: selected)
            }
        }
        if let presented = viewController?.presentedViewController {
            return topViewController(viewController: presented)
        }
        return viewController
    }
}

extension CMTime {
    var durationText:String {
        let totalSeconds = CMTimeGetSeconds(self)
        let hours:Int = Int(totalSeconds / 3600)
        let minutes:Int = Int(totalSeconds.truncatingRemainder(dividingBy: 3600) / 60)
        let seconds:Int = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        
        if hours > 0 {
            return String(format: "%i:%02i:%02i", hours, minutes, seconds)
        } else {
            return String(format: "%02i:%02i", minutes, seconds)
        }
    }
}




struct AppFontName {
    static let regular = "IRANYekanMobile"
    static let bold = "IRANYekanMobile"
    static let italic = "IRANYekanMobile"
}

extension UIFontDescriptor.AttributeName {
    static let nsctFontUIUsage =
        UIFontDescriptor.AttributeName(rawValue: "NSCTFontUIUsageAttribute")
}

public extension String {
    
    var englishDigits:String{
        
        var stringValue = self
        
        
        var engDigit = ["1","2","3","4","5","6","7","8","9","0"]
        var faDigit = ["۱","۲","۳","۴","۵","۶","۷","۸","۹","۰"]
        var arabDigit = ["١","٢","٣","٤","٥","٦","٧","٨","٩","٠"]
        for i in 0..<engDigit.count{
            stringValue = stringValue.replacingOccurrences(of: faDigit[i], with: engDigit[i])
            stringValue = stringValue.replacingOccurrences(of: arabDigit[i], with: engDigit[i])
        }
        
        return stringValue
    }
    
    var persianDigits:String{
        
        var stringValue = self
        
        
        var engDigit = ["1","2","3","4","5","6","7","8","9","0"]
        var faDigit = ["۱","۲","۳","۴","۵","۶","۷","۸","۹","۰"]
        var arabDigit = ["١","٢","٣","٤","٥","٦","٧","٨","٩","٠"]
        for i in 0..<engDigit.count{
            stringValue = stringValue.replacingOccurrences(of: engDigit[i], with: faDigit[i])
//            stringValue = stringValue.replacingOccurrences(of: engDigit[i], with: engDigit[i])
        }
        
        return stringValue
    }
}

extension NSMutableAttributedString {
    @discardableResult func bold(_ text: String) -> NSMutableAttributedString {
        let attrs: [NSAttributedStringKey: Any] = [.font: UIFont.systemFont(ofSize: 15)]
        let boldString = NSMutableAttributedString(string:text, attributes: attrs)
        append(boldString)
        
        return self
    }
    
    @discardableResult func normal(_ text: String) -> NSMutableAttributedString {
        let normal = NSAttributedString(string: text)
        append(normal)
        
        return self
    }
}

extension UIFont {
    
    @objc class func mySystemFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.regular, size: size)!
    }
    
    @objc class func myBoldSystemFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.bold, size: size)!
    }
    
    @objc class func myItalicSystemFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.italic, size: size)!
    }
    
    @objc convenience init(myCoder aDecoder: NSCoder) {
        if let fontDescriptor = aDecoder.decodeObject(forKey: "UIFontDescriptor") as? UIFontDescriptor {
            if let fontAttribute = fontDescriptor.fontAttributes[.nsctFontUIUsage] as? String {
                var fontName = ""
                switch fontAttribute {
                case "CTFontRegularUsage":
                    fontName = AppFontName.regular
                case "CTFontEmphasizedUsage", "CTFontBoldUsage":
                    fontName = AppFontName.bold
                case "CTFontObliqueUsage":
                    fontName = AppFontName.italic
                default:
                    fontName = AppFontName.regular
                }
                self.init(name: fontName, size: fontDescriptor.pointSize)!
            }
            else {
                self.init(myCoder: aDecoder)
            }
        }
        else {
            self.init(myCoder: aDecoder)
        }
    }
    
    class func overrideInitialize() {
        if self == UIFont.self {
            let systemFontMethod = class_getClassMethod(self, #selector(systemFont(ofSize:)))
            let mySystemFontMethod = class_getClassMethod(self, #selector(mySystemFont(ofSize:)))
            method_exchangeImplementations(systemFontMethod!, mySystemFontMethod!)
            
            let boldSystemFontMethod = class_getClassMethod(self, #selector(boldSystemFont(ofSize:)))
            let myBoldSystemFontMethod = class_getClassMethod(self, #selector(myBoldSystemFont(ofSize:)))
            method_exchangeImplementations(boldSystemFontMethod!, myBoldSystemFontMethod!)
            
            let italicSystemFontMethod = class_getClassMethod(self, #selector(italicSystemFont(ofSize:)))
            let myItalicSystemFontMethod = class_getClassMethod(self, #selector(myItalicSystemFont(ofSize:)))
            method_exchangeImplementations(italicSystemFontMethod!, myItalicSystemFontMethod!)
            
            let initCoderMethod = class_getInstanceMethod(self, #selector(UIFontDescriptor.init(coder:))) // Trick to get over the lack of UIFont.init(coder:))
            let myInitCoderMethod = class_getInstanceMethod(self, #selector(UIFont.init(myCoder:)))
            method_exchangeImplementations(initCoderMethod!, myInitCoderMethod!)
        }
    }
}


