//
//  LineView.swift
//  Izhikevich
//
//  Created by Colin Prepscius on 5/9/15.
//  Copyright (c) 2015 Infinite State Machine Inc. All rights reserved.
//

import UIKit

class LineView: UIView {

    var width: CGFloat = 1.0
    var color: UIColor = UIColor.lightGrayColor()
    
    override func drawRect(rect: CGRect) {
        let linePath = UIBezierPath()
        linePath.lineWidth = width
        linePath.moveToPoint(CGPoint(x:0, y:1))
        linePath.addLineToPoint(CGPoint(x:self.bounds.size.width, y:1))
        linePath.setLineDash([10.0, 5.0], count: 2, phase: 0)
        color.setStroke()
        linePath.stroke()
    }
}
