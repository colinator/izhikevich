//
//  GraphRenderView.swift
//  Izhikevich
//
//  Created by Colin Prepscius on 5/8/15.
//  Copyright (c) 2015 Infinite State Machine Inc. All rights reserved.
//

import UIKit

class GraphRenderView: UIView {

    var minY = 0.0
    var maxY = 0.0
    var data = [Double](count: 1000, repeatedValue: 0.0)
    
    func setNewData(newData: [Double], newMinY: Double, newMaxY: Double) {
        data = newData
        minY = newMinY
        maxY = newMaxY
    }
    
    override func drawRect(rect: CGRect) {
        
        let inset = 5.0
        let path = UIBezierPath()
        
        path.lineWidth = 0.5
        
        let dy = max(1.0, maxY - minY)
        let m = (-1.0 * (Double(self.bounds.size.height) - 2.0 * inset)) / dy
        let b = -1.0 * maxY * m

        for (index, d) in data.enumerate() {
            let y = m * d + b + inset
            if index == 0 {
                path.moveToPoint(CGPoint(x:0.0, y:y))
            } else {
                let k = Double(self.bounds.size.width) / Double(data.count)
                path.addLineToPoint(CGPoint(x:Double(index) * k, y:y))
            }
        }
        
        UIColor.blackColor().setStroke()
        
        path.stroke()
    }
}
