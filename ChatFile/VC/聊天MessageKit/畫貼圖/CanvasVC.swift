//
//  CanvasVC.swift
//  ChatFile
//
//  Created by 2008007NB01 on 2021/10/27.
//

import UIKit

protocol sendStickerDelegate {
    func sendTicker(img:UIImage)
}

class CanvasVC: UIViewController {
    
    @IBOutlet weak var canvas: Canvas!
    @IBOutlet weak var canvasHeight: NSLayoutConstraint!
    
    var delegate:sendStickerDelegate?
    var imgSticker:UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        canvasHeight.constant = UIScreen.WIDTH - 40
        canvas.clipsToBounds = true
        canvas.isMultipleTouchEnabled = false
    }

    @IBAction func action_back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func action_save(_ sender: Any) {
        if canvas.startingPoint == nil { // 未畫貼圖
            AlertUtil.showMessage(message: "未畫貼圖唷～")
        } else {
            let screenshot = self.canvas.takeScreenShot()
            imgSticker = screenshot
            delegate?.sendTicker(img:imgSticker!)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func action_delete(_ sender: Any) {
        canvas.clearCanvas()
    }
}


