//
//  ImageCache.swift
//  ChatFile
//
//  Created by 2008007NB01 on 2021/10/20.
//

import Foundation
import UIKit

public enum LoadingStyle {
    case Default
    case Circle
}

@available(iOS 10.0, *)
public final class LoadingManager: NSObject {
    public static var arrLoadingView: [LoadingUtil] = []
    
    public static func removeAllLoadingView() {
        LoadingManager.arrLoadingView.removeAll()
    }
    
    public static func removeLoadingView(view: UIView) {
        for (index,util) in LoadingManager.arrLoadingView.enumerated() {
            if util.vwTemp == view {
                LoadingManager.arrLoadingView.remove(at: index)
                break
            }
        }
    }

    public static func showAndReplace(view: UIView) {
        var isFind = false
        var utilObj: LoadingUtil?
        for util in LoadingManager.arrLoadingView {
            if util.vwTemp == view {
                isFind = true
                utilObj = util
                break
            }
        }
        
        if isFind {
            utilObj?.showAndReplace(view: view)
        } else {
            utilObj = LoadingUtil.init(view: view)
            utilObj?.showAndReplace(view: view)
            LoadingManager.arrLoadingView.append(utilObj!)
        }
    }
    
    public static func hideAndReplace(view: UIView) {
        var isFind = false
        var utilObj: LoadingUtil?
        for util in LoadingManager.arrLoadingView {
            if util.vwTemp == view {
                isFind = true
                utilObj = util
                break
            }
        }
        
        if isFind {
            utilObj?.hideAndReplace(view: view)
        }
    }
}

@available(iOS 10.0, *)
public final class LoadingUtil: NSObject {
    
    public static let shared = LoadingUtil()
    
    fileprivate var vwTemp: UIView?
    
    // LoadingUI Type
    private var aiv = UIActivityIndicatorView()
    private var spView = SpinningView()
    
    private var vwBG = UIView()
    private var vwBase = UIView()
    private var vwSquareShadow = UIView()
    private var vwSquare = UIView()
    private var lbTitle = UILabel()
    private var lbStatus = UILabel()
    private var tapGesture: UITapGestureRecognizer?
    private var tapCount: Int = 0
    private var CancelBlock: (() -> Void)?
    private var timer: Timer?
    
    //MARK: - 可控制項目
    public static var style: LoadingStyle?
    
    public static var vwBG_Color: UIColor?
    public static var vwSquare_Color: UIColor?
    public static var vwBG_Alpha: CGFloat?
    public static var vwSquare_Alpha: CGFloat?
    public static var lbTitle_Color: UIColor?
    public static var lbStatus_Color: UIColor?
    public static var circleColor: UIColor?
    
    private override init() {
        self.vwBG = UIView.init(frame: UIScreen.main.bounds)
        self.vwBG.center = CGPoint(x: UIScreen.WIDTH/2, y: UIScreen.HEIGHT/2)
        self.vwBG.backgroundColor = LoadingUtil.vwBG_Color ?? .black
        self.vwBG.alpha = LoadingUtil.vwBG_Alpha ?? 0.3

        self.vwBase = UIView.init(frame: UIScreen.main.bounds)
        self.vwBase.center = CGPoint(x: UIScreen.WIDTH/2, y: UIScreen.HEIGHT/2)
        self.vwBase.backgroundColor = .clear

        self.vwSquareShadow = UIView.init(frame:
            CGRect(x: 0, y: 0, width: 130, height: 130))
        self.vwSquareShadow.center = self.vwBase.center
        self.vwSquareShadow.backgroundColor = .red
        self.vwSquareShadow.alpha = 0.2
        self.vwSquareShadow.layer.cornerRadius = 10
        self.vwSquareShadow.layer.masksToBounds = true
        self.vwSquareShadow.isHidden = true
        self.vwBase.addSubview(self.vwSquareShadow)

        self.vwSquare = UIView.init(frame:
            CGRect(x: 0, y: 0, width: 120, height: 120))
        self.vwSquare.center = self.vwBase.center
        self.vwSquare.backgroundColor = LoadingUtil.vwSquare_Color ?? .black
        self.vwSquare.alpha = LoadingUtil.vwSquare_Alpha ?? 0.8
        self.vwSquare.layer.cornerRadius = 10
        self.vwSquare.layer.masksToBounds = true
        self.vwBase.addSubview(vwSquare)

        if LoadingUtil.style == .Circle{
            self.spView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            spView.center = self.vwBase.center
            self.vwBase.addSubview(spView)
        }else{
            self.aiv = UIActivityIndicatorView.init(style: .whiteLarge)
            self.aiv.center = self.vwBase.center
            self.aiv.startAnimating()
            self.vwBase.addSubview(self.aiv)
        }
        
        self.lbTitle = UILabel.init(frame:
            CGRect(x: 0, y: 0, width: 120, height: 30))
        self.lbTitle.center = CGPoint(x: UIScreen.WIDTH/2, y: UIScreen.HEIGHT/2 - 35)
        self.lbTitle.backgroundColor = .clear
        self.lbTitle.textColor = LoadingUtil.lbTitle_Color ?? .white
        self.lbTitle.font = UIFont.systemFont(ofSize: 16)
        self.lbTitle.textAlignment = .center
        self.lbTitle.numberOfLines = 1
        self.vwBase.addSubview(self.lbTitle)

        self.lbStatus = UILabel.init(frame:
            CGRect(x: 0, y: 0, width: 120, height: 30))
        self.lbStatus.center = CGPoint(x: UIScreen.WIDTH/2, y: UIScreen.HEIGHT/2 + 35)
        self.lbStatus.backgroundColor = .clear
        self.lbStatus.textColor = LoadingUtil.lbStatus_Color ?? .white
        self.lbStatus.font = UIFont.systemFont(ofSize: 16)
        self.lbStatus.textAlignment = .center
        self.lbStatus.numberOfLines = 1
        self.vwBase.addSubview(self.lbStatus)

        self.tapCount = 0
    }
    
    fileprivate init(view: UIView) {
        var frame: CGRect?
        if view.frame.size.width > view.frame.size.height {
            frame = CGRect(x: 0, y: 0,
                           width: view.frame.size.height,
                           height: view.frame.size.height)
        } else {
            frame = CGRect(x: 0, y: 0,
                           width: view.frame.size.width,
                           height: view.frame.size.width)
        }
        
        self.vwBase = UIView.init(frame: frame!)
        self.vwBase.center = view.center
        self.vwBase.backgroundColor = .clear

        if LoadingUtil.style == .Circle{
            self.spView.frame = self.vwBase.frame
            self.spView.center = CGPoint(x: frame!.size.width/2, y: frame!.size.height/2)
            self.vwBase.addSubview(self.spView)
        }else{
            self.aiv = UIActivityIndicatorView.init(style: .whiteLarge)
            self.aiv.center = CGPoint(x: frame!.size.width/2, y: frame!.size.height/2)
            self.aiv.startAnimating()
            self.vwBase.addSubview(self.aiv)
        }
        self.vwTemp = view

        // 加入到Label的父View
        view.superview?.addSubview(self.vwBase)
    }
        
    internal func showAndReplace(view: UIView) {
        // 隱藏(Label)
        view.isHidden = true
        
        // 顯示(Loading)
        self.vwBase.isHidden = false
    }
    
    internal func hideAndReplace(view: UIView) {
        // 顯示(Label)
        view.isHidden = false
        
        // 隱藏(Loading)
        self.vwBase.isHidden = true
    }

    @objc (hideView)
    public static func hideView() {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.2, options: .curveEaseInOut, animations: {
            //放大
            LoadingUtil.shared.vwBase.transform = CGAffineTransform.init(scaleX: 4, y: 4)
            LoadingUtil.shared.vwBase.alpha = 0

            if LoadingUtil.shared.tapGesture != nil {
                LoadingUtil.shared.vwBase.removeGestureRecognizer(LoadingUtil.shared.tapGesture!)
            }
        }) { (finished) in
            LoadingUtil.shared.vwBase.transform = .identity
            
            LoadingUtil.shared.vwBG.removeFromSuperview()
            LoadingUtil.shared.vwBase.removeFromSuperview()
            
            // 回復初始
            LoadingUtil.shared.vwBase.alpha = 1
            LoadingUtil.shared.vwSquareShadow.isHidden = true
        }
    }
    
    @objc (hideViewWithTap)
    public static func hideViewWithTap() {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.2, options: .curveEaseInOut, animations: {
            //縮小
            LoadingUtil.shared.vwBase.transform = CGAffineTransform.init(scaleX: 0.8, y: 0.8)
            
            if LoadingUtil.shared.tapGesture != nil {
                LoadingUtil.shared.vwBase.removeGestureRecognizer(LoadingUtil.shared.tapGesture!)
            }
        }) { (finished) in
            LoadingUtil.shared.vwBase.transform = .identity
            
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.2, options: .curveEaseInOut, animations: {
                //放大
                LoadingUtil.shared.vwBase.transform = CGAffineTransform.init(scaleX: 4, y: 4)
                LoadingUtil.shared.vwBase.alpha = 0
            }) { (finished) in
                LoadingUtil.shared.vwBase.transform = .identity
                
                LoadingUtil.shared.vwBG.removeFromSuperview()
                LoadingUtil.shared.vwBase.removeFromSuperview()
                
                // 回復初始
                LoadingUtil.shared.vwBase.alpha = 1
                LoadingUtil.shared.vwSquareShadow.isHidden = true
                LoadingUtil.shared.tapCount = 0
                
                // 丟出CallBack
                if LoadingUtil.shared.CancelBlock != nil {
                    LoadingUtil.shared.CancelBlock!()
                }
            }
        }
    }
    
    // 為了適應橫向
    public static func resetFrame() {
        let frame = UIScreen.main.bounds
        LoadingUtil.shared.vwBG.frame = frame
        LoadingUtil.shared.vwBG.center = CGPoint(x: frame.width/2, y: frame.height/2)

        LoadingUtil.shared.vwBase.frame = UIScreen.main.bounds
        LoadingUtil.shared.vwBase.center = LoadingUtil.shared.vwBG.center

        LoadingUtil.shared.vwSquareShadow.center = LoadingUtil.shared.vwBase.center
        LoadingUtil.shared.vwSquare.center = LoadingUtil.shared.vwBase.center
        LoadingUtil.shared.aiv.center = LoadingUtil.shared.vwBase.center

        LoadingUtil.shared.lbTitle.center = CGPoint(x: frame.width/2, y: frame.height/2 - 35)
        LoadingUtil.shared.lbStatus.center = CGPoint(x: frame.width/2, y: frame.height/2 - 35)
    }

    @objc (showWithTitle:)
    public static func showWithTitle(title: String) {
        LoadingUtil.shared.lbStatus.text = title
        if LoadingUtil.style == .Circle{
            LoadingUtil.shared.spView.updateAnimation()
        }
        
        if let window = UIWindow.topWindow {
            window.addSubview(LoadingUtil.shared.vwBG)
            window.addSubview(LoadingUtil.shared.vwBase)
        }
        
    }

    @objc (showWithTitle:hideDelay:)
    public static func showWithTitle(title: String, hideDelay: TimeInterval) {
        LoadingUtil.shared.lbStatus.text = title
        
        LoadingUtil.shared.timer = Timer.scheduledTimer(withTimeInterval: hideDelay, repeats: false, block: { (timer) in
            LoadingUtil.hideView()
            LoadingUtil.shared.timer?.invalidate()
        })

        if let window = UIWindow.topWindow {
            window.addSubview(LoadingUtil.shared.vwBG)
            window.addSubview(LoadingUtil.shared.vwBase)
        }
    }

    @available(iOS 10.0, *)
    @objc (showWithTitle:status:)
    public static func showWithTitle(title: String, status: String) {
        LoadingUtil.shared.lbTitle.text = title
        LoadingUtil.shared.lbStatus.text = status

        if let window = UIWindow.topWindow {
            window.addSubview(LoadingUtil.shared.vwBG)
            window.addSubview(LoadingUtil.shared.vwBase)
        }
        
        LoadingUtil.shared.tapGesture = UITapGestureRecognizer.init(target: LoadingUtil.shared, action: #selector(hudWasCancelled))
        LoadingUtil.shared.vwBase.addGestureRecognizer(LoadingUtil.shared.tapGesture!)
    }
    
    @objc (showWithTitle:status:cancelBlock:)
    public static func showWithTitle(title: String, status: String, cancelBlock: @escaping (() -> Void)) {
        LoadingUtil.showWithTitle(title: title, status: status)
        LoadingUtil.shared.CancelBlock = cancelBlock
    }
    
    @objc (updateTitle:status:)
    public static func updateTitle(title: String, status: String) {
        LoadingUtil.shared.lbTitle.text = title
        LoadingUtil.shared.lbStatus.text = status
    }
    
    @objc func hudWasCancelled(sender: UITapGestureRecognizer) {
//        LoadingUtil.shared.lbStatus.text = "確定取消？"

        tapCount = tapCount + 1
        if sender.state == .ended {
            if tapCount == 1 {
                LoadingUtil.shared.timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true, block: { (timer) in
                    LoadingUtil.shared.vwSquareShadow.isHidden = !LoadingUtil.shared.vwSquareShadow.isHidden
                })
            }else if tapCount == 2 {
                if LoadingUtil.shared.timer != nil {
                    LoadingUtil.shared.timer?.invalidate()
                }
                LoadingUtil.hideViewWithTap()
            }
        }
    }
}


//MARK:- circle Style
class SpinningView: UIView {

    let circleLayer = CAShapeLayer()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2 - circleLayer.lineWidth/2

        let startAngle = CGFloat(-CGFloat.pi/2)
        let endAngle = startAngle + CGFloat(CGFloat.pi * 2)
        let path = UIBezierPath(arcCenter: .zero, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)

        circleLayer.position = center
        circleLayer.path = path.cgPath
    }
    
    func setup() {
        circleLayer.lineWidth = lineWidth
        circleLayer.fillColor = nil
        circleLayer.strokeColor = UIColor.red.cgColor
        layer.addSublayer(circleLayer)
        
        tintColorDidChange()
        updateAnimation()
    }
    
    override func tintColorDidChange() {
        super.tintColorDidChange()
        //circleLayer.strokeColor = tintColor.cgColor
        //circleLayer.strokeColor = UIColor.white.cgColor
        if #available(iOS 10.0, *) {
            circleLayer.strokeColor = LoadingUtil.circleColor?.cgColor ?? UIColor.white.cgColor
        } else {
            circleLayer.strokeColor = UIColor.white.cgColor
        }
    }
    
    @IBInspectable var lineWidth: CGFloat = 4 {
        didSet {
            circleLayer.lineWidth = lineWidth
            setNeedsLayout()
        }
    }
    
    @IBInspectable var animating: Bool = true {
        didSet {
            updateAnimation()
        }
    }
    
    let strokeEndAnimation: CAAnimation = {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = 1
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)

        let group = CAAnimationGroup()
        group.duration = 1.5
        group.repeatCount = MAXFLOAT
        group.animations = [animation]
        return group
        }()

    let strokeStartAnimation: CAAnimation = {
        let animation = CABasicAnimation(keyPath: "strokeStart")
        animation.beginTime = 0.5
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = 1
        
        let group = CAAnimationGroup()
        group.duration = 1.5
        group.repeatCount = MAXFLOAT
        group.animations = [animation]

        return group
        }()

    let rotationAnimation: CAAnimation = {
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.fromValue = 0
        animation.toValue = CGFloat.pi * 2
        animation.duration = 4
        animation.repeatCount = MAXFLOAT
        
        return animation
    }()
    
    func updateAnimation() {
        if animating {
            circleLayer.add(strokeEndAnimation, forKey: "strokeEnd")
            circleLayer.add(strokeStartAnimation, forKey: "strokeStart")
            circleLayer.add(rotationAnimation, forKey: "rotation")
        } else {
            circleLayer.removeAnimation(forKey: "strokeEnd")
            circleLayer.removeAnimation(forKey: "strokeStart")
            circleLayer.removeAnimation(forKey: "rotation")
        }
    }
}

