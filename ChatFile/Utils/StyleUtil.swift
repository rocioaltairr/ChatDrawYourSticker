//
//  StyleUtil.swift
//  ChatFile
//
//  Created by 白白 on 2021/10/15.
//

import Foundation
import UIKit

open class StyleView: UIView{
    
    public enum ShadowPositionType: Int {
        case None = 0
        case Top
        case Bottom
        case BottomRight
    }
    
    @IBInspectable open var CornerRadius: CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = CornerRadius
            //layer.masksToBounds = CornerRadius > 0
        }
    }
    
    @IBInspectable open var BorderWidth: CGFloat = 0.0 {
        didSet {
            layer.borderWidth = BorderWidth
        }
    }
    
    @IBInspectable open var BorderColor: UIColor = UIColor.clear {
        didSet {
            layer.borderColor = BorderColor.cgColor
        }
    }
    
    @IBInspectable public var ShadowType: Int = 0{
        didSet {
            switch ShadowType {
            case ShadowPositionType.Top.rawValue:
                layer.shadowOffset = CGSize(width: 0, height: -2)
                layer.shadowOpacity = 0.4
                layer.shadowRadius = 3.0
                layer.shadowColor = UIColor.black.cgColor
            case ShadowPositionType.Bottom.rawValue:
                layer.shadowOffset = CGSize(width: 0, height: 2)
                layer.shadowOpacity = 0.4
                layer.shadowRadius = 2.0
                layer.shadowColor = UIColor.black.cgColor
            case ShadowPositionType.BottomRight.rawValue:
                layer.shadowOffset = CGSize(width: 1, height: 2)
                layer.shadowOpacity = 0.3
                layer.shadowRadius = 2.0
                layer.shadowColor = UIColor.black.cgColor
            default:
                layer.shadowColor = UIColor.clear.cgColor
            }
        }
    }
    
    @IBInspectable public var St1Top: String = "Top"{
        didSet {}
    }
    @IBInspectable public var St2Bottom: String = "Bottom"{
        didSet {}
    }
    @IBInspectable public var St3BottomRight: String = "BottomRight"{
        didSet {}
    }

//    @IBInspectable public var ShadowTopEnable: Bool = true {
//        didSet {
//            if ShadowTopEnable == true {
//                ShadowBottomEnable = false
//                ShadowBottomRightEnable = false
//
//                layer.shadowOffset = CGSize(width: 0, height: -2)
//                layer.shadowOpacity = 0.4
//                layer.shadowRadius = 3.0
//                layer.shadowColor = UIColor.black.cgColor
//            } else {
//                layer.shadowColor = UIColor.clear.cgColor
//            }
//        }
//    }
//    @IBInspectable public var ShadowBottomEnable: Bool = true {
//        didSet {
//            if ShadowBottomEnable == true {
//                ShadowTopEnable = false
//                ShadowBottomRightEnable = false
//
//                layer.shadowOffset = CGSize(width: 0, height: 2)
//                layer.shadowOpacity = 0.4
//                layer.shadowRadius = 2.0
//                layer.shadowColor = UIColor.black.cgColor
//            } else {
//                layer.shadowColor = UIColor.clear.cgColor
//            }
//        }
//    }
//    @IBInspectable public var ShadowBottomRightEnable: Bool = true {
//        didSet {
//            if ShadowBottomRightEnable == true {
//                ShadowTopEnable = false
//                ShadowBottomEnable = false
//
//                layer.shadowOffset = CGSize(width: 1, height: 2)
//                layer.shadowOpacity = 0.3
//                layer.shadowRadius = 2.0
//                layer.shadowColor = UIColor.black.cgColor
//            } else {
//                layer.shadowColor = UIColor.clear.cgColor
//            }
//        }
//    }
    
    @IBInspectable public var ShadowEnable: Bool = true {
        didSet {
            if ShadowEnable == true {
                layer.shadowOffset = CGSize(width: 0, height: 2)
                layer.shadowOpacity = 0.8
                layer.shadowRadius = 2.0
                layer.shadowColor = UIColor.black.cgColor
            } else {
                layer.shadowColor = UIColor.clear.cgColor
            }
        }
    }

    @IBInspectable public var ShadowColor: UIColor = UIColor.clear {
        didSet {
            layer.shadowColor = ShadowColor.cgColor
        }
    }

    @IBInspectable public var ShadowOffset: CGSize = CGSize(width: 0.0, height: 0.0) {
        didSet {
            layer.shadowOffset = ShadowOffset
        }
    }

    @IBInspectable public var shadowOpacity: Float = 0.0 {
        didSet {
            layer.shadowOpacity = shadowOpacity
        }
    }
    @IBInspectable public var shadowRadius: CGFloat = 0.0 {
        didSet {
            layer.shadowRadius = shadowRadius
        }
    }
}

//@IBDesignable

open class StyleButton: UIButton{
    
    @IBInspectable open var CornerRadius: CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = CornerRadius
            //layer.masksToBounds = CornerRadius > 0
        }
    }
    
    @IBInspectable open var BorderWidth: CGFloat = 0.0 {
        didSet {
            layer.borderWidth = BorderWidth
        }
    }
    
    @IBInspectable open var BorderColor: UIColor = UIColor.clear {
        didSet {
            layer.borderColor = BorderColor.cgColor
        }
    }

    @IBInspectable public var ShadowEnable: Bool = true {
        didSet {
            if ShadowEnable == true {
                layer.shadowOffset = CGSize(width: 0, height: 2)
                layer.shadowOpacity = 0.8
                layer.shadowRadius = 2.0
                layer.shadowColor = UIColor.black.cgColor
                
            } else {
                layer.shadowColor = UIColor.clear.cgColor
            }
        }
    }
    
    @IBInspectable public var ShadowColor: UIColor = UIColor.clear {
        didSet {
            layer.shadowColor = ShadowColor.cgColor
        }
    }
    
    @IBInspectable public var ShadowOffset: CGSize = CGSize(width: 0.0, height: 0.0) {
        didSet {
            layer.shadowOffset = ShadowOffset
        }
    }
    
    @IBInspectable public var shadowOpacity: Float = 0.0 {
        didSet {
            layer.shadowOpacity = shadowOpacity
        }
    }
    @IBInspectable public var shadowRadius: CGFloat = 0.0 {
        didSet {
            layer.shadowRadius = shadowRadius
        }
    }
    
    @IBInspectable open var touchDownColor: UIColor = .clear
    @IBInspectable open var touchUpColor: UIColor = .clear
    @IBInspectable open var touchDownScale: CGFloat = 0.9
    
    func setupTouchEvent() {
        print("setupTouchEvent")
        self.addTarget(self, action: #selector(acTouchUp), for: .touchUpInside)
        self.addTarget(self, action: #selector(acTouchUp), for: .touchUpOutside)
        self.addTarget(self, action: #selector(acTouchDown), for: .touchDown)
    }
    
    @objc func acTouchDown() {
        self.transform = CGAffineTransform(scaleX: touchDownScale, y: touchDownScale)
        self.backgroundColor = touchDownColor
    }

    @objc func acTouchUp() {
        self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        self.backgroundColor = touchUpColor
    }
}

