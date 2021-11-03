//
//  Canvas.swift
//  recordS
//
//  Created by user on 2020/6/10.
//  Copyright © 2020 user. All rights reserved.
//

import UIKit

class Canvas: UIView {

    var lineColor = UIColor.black
    var lineWidth:CGFloat = 10
    var path:UIBezierPath!
    var touchPoint:CGPoint!
    var startingPoint:CGPoint!
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        startingPoint = touches.first?.location(in: self)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchPoint = touches.first?.location(in: self)
        path = UIBezierPath()
        path.move(to: startingPoint)
        path.addLine(to: touchPoint)
        startingPoint = touchPoint
        draw()
    }
    
    func draw(){
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = lineColor.cgColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.fillColor = UIColor.clear.cgColor
        self.layer.addSublayer(shapeLayer)
        self.setNeedsDisplay()
    }
    
    func clearCanvas(){
        path.removeAllPoints()
        self.layer.sublayers = nil
        self.setNeedsDisplay()
    }
    
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
