//
//  InputCurrentCreationView.swift
//  Izhikevich
//
//  Created by Colin Prepscius on 5/9/15.
//  Copyright (c) 2015 Infinite State Machine Inc. All rights reserved.
//

import UIKit


let MaxValueButtonWidth: CGFloat = 50.0
let MaxValueButtonHeight: CGFloat = 20.0

class InputCurrentDrawingView: UIControl {

    var currentValues = [Double](count: 1000, repeatedValue: 0.0)
    
    let inset = 10.0
    let maxY = 10.0
    
    var dMax = 0.0
    var yMin = 10000000.0
    
    var previousLocation : CGPoint?
    
    func getCurrentValues() -> Array<Double> {
        return currentValues
    }

    func cutCurrentValuesToMax(maxV: Double) {
        for (i, v) in currentValues.enumerate() {
            currentValues[i] = min(maxV, v)
        }
        self.setNeedsDisplay()
    }
    
    func setValuesFromLocation(location: CGPoint) {
        
        let dy = -1.0 * maxY
        let dx = Double(self.bounds.size.height) - 2.0 * inset
        let m = dy / dx
        let b = -1.0 * m * (Double(self.bounds.size.height) - inset)
        
        if let prev = previousLocation {
            
            var i1 = Int(location.x * 1000.0 / self.bounds.size.width)
            var i2 = Int(prev.x * 1000.0 / self.bounds.size.width)
            
            if i1 == i2 {
                let i = i1
                if i >= 0 && i < 1000 {
                    var y = m * Double(location.y) + b
                    y = max(min(y, maxY), 0)
                    currentValues[i] = y
                    previousLocation = location
                }
            } else {
                var y1 = m * Double(location.y) + b
                var y2 = m * Double(prev.y) + b
                
                if (i1 > i2) {
                    let ti = i1
                    i1 = i2
                    i2 = ti
                    let ty = y1
                    y1 = y2
                    y2 = ty
                }
                let m2 = (y2 - y1) / Double(i2 - i1)
                let b2 = y2 - m2 * Double(i2)
                for i in i1...i2 {
                    if i >= 0 && i < 1000 {
                        var y = m2 * Double(i) + b2
                        y = max(min(y, maxY), 0)
                        currentValues[i] = y
                    }
                }
                previousLocation = location
            }
        } else {
            let i = Int(location.x * 1000.0 / self.bounds.size.width)
            if i >= 0 && i < 1000 {
                var y = m * Double(location.y) + b
                y = max(min(y, maxY), 0)
                currentValues[i] = y
                previousLocation = location
            }
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.locationInView(self)
            setValuesFromLocation(location)
            self.setNeedsDisplay()
            self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.locationInView(self)
            setValuesFromLocation(location)
            self.setNeedsDisplay()
            self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        previousLocation = nil
        self.sendActionsForControlEvents(UIControlEvents.EditingDidEnd)
    }
    
    func yFromScreenY(sy: CGFloat) -> CGFloat {
        let m = -1.0 * maxY / (Double(self.bounds.size.height) - 2.0 * inset)
        let b = -1.0 * m * (Double(self.bounds.size.height) - inset)
        let y = m * Double(sy) + b
        return CGFloat(max(min(maxY, y), 0.0))
    }
    
    func screenYFromY(y: CGFloat) -> CGFloat {
        let m = (-1.0 * (Double(self.bounds.size.height) - 2.0 * inset)) / maxY
        let b = Double(self.bounds.size.height) - inset
        let sy = m * Double(y) + b
        return CGFloat(sy)
    }
    
    override func drawRect(rect: CGRect) {
        let path = UIBezierPath()
        
        path.lineWidth = 0.5
        
        let m = (-1.0 * (Double(self.bounds.size.height) - 2.0 * inset)) / maxY
        let b = -1.0 * maxY * m
        
        dMax = 0.0
        yMin = 10000000.0
        
        for (index, d) in currentValues.enumerate() {
            let y = m * d + b + inset
            if index == 0 {
                path.moveToPoint(CGPoint(x:0.0, y:y))
            } else {
                path.addLineToPoint(CGPoint(x:Double(index) * 0.5, y:y))
            }
            dMax = max(d, dMax)
            yMin = min(y, yMin)
        }
        
        UIColor.blackColor().setStroke()
        
        path.stroke()
        
    }
}

class InputCurrentCreationView: UIControl {
    
    var inputDrawingView: InputCurrentDrawingView?
    var lineView: LineView?
    var maxValueButton: UIButton?
    
    var startMaxbuttonLocation: CGPoint?
    
    func getCurrentValues() -> [Double] {
        return inputDrawingView!.getCurrentValues()
    }
    
    func setCurrentValues(input: [Double]) {
        inputDrawingView!.currentValues = input
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        inputDrawingView = InputCurrentDrawingView(frame:CGRectMake(0, 0, self.bounds.size.width - MaxValueButtonWidth, self.bounds.size.height))
        inputDrawingView?.backgroundColor = self.backgroundColor
        inputDrawingView?.addTarget(self, action: "inputCurrentValuesChanged", forControlEvents: .ValueChanged)
        inputDrawingView?.addTarget(self, action: "inputCurrentValuesFinishedChanging", forControlEvents: .EditingDidEnd)
        self.addSubview(inputDrawingView!)
        
        maxValueButton = UIButton(frame: CGRectMake(self.bounds.size.width, 0, MaxValueButtonWidth, MaxValueButtonHeight))
        maxValueButton?.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        maxValueButton?.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        maxValueButton?.titleLabel?.font = UIFont.boldSystemFontOfSize(14)
        maxValueButton?.setTitle("filter", forState: .Normal)
        maxValueButton?.addTarget(self, action: "maxButtonDown:event:", forControlEvents: .TouchDown)
        maxValueButton?.addTarget(self, action: "maxButtonMove:event:", forControlEvents: .TouchDragInside)
        maxValueButton?.addTarget(self, action: "maxButtonMove:event:", forControlEvents: .TouchDragOutside)
        maxValueButton?.addTarget(self, action: "maxButtonUp:event:", forControlEvents: .TouchUpInside)
        maxValueButton?.addTarget(self, action: "maxButtonUp:event:", forControlEvents: .TouchUpOutside)
        self.addSubview(maxValueButton!)
        
        lineView = LineView(frame: CGRectMake(0, 0, self.bounds.size.width, 3.0))
        lineView?.backgroundColor = UIColor.clearColor()
        lineView?.width = 0.5
        lineView?.color = UIColor(white:0.6, alpha: 0.5)
        self.addSubview(lineView!)

        self.backgroundColor = UIColor.clearColor()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        inputDrawingView?.frame = CGRectMake(0, 0, self.bounds.size.width - MaxValueButtonWidth, self.bounds.size.height)
        maxValueButton?.frame = CGRectMake(self.bounds.size.width - MaxValueButtonWidth, 0, MaxValueButtonWidth, MaxValueButtonHeight)
        lineView!.frame = CGRectMake(0, 0, self.bounds.size.width, 3.0)
    }
    
    func maxButtonDown(buttn: UIButton, event: UIEvent) {
        let touch: UITouch = event.touchesForView(buttn)!.first!
        startMaxbuttonLocation = touch.locationInView(buttn)
    }
    
    func maxButtonMove(buttn : UIButton, event: UIEvent) {
        let touch: UITouch = event.touchesForView(buttn)!.first!
        let location: CGPoint = touch.locationInView(self)
        let topY = location.y - startMaxbuttonLocation!.y
        let sy = topY + MaxValueButtonHeight
        let ay = inputDrawingView!.yFromScreenY(sy)
        let snY = inputDrawingView!.screenYFromY(ay)
        
        maxValueButton?.setTitle(String(format:"%.3f", ay), forState: UIControlState.Normal)
        maxValueButton?.frame = CGRectMake(self.bounds.size.width - MaxValueButtonWidth, snY - MaxValueButtonHeight, MaxValueButtonWidth, MaxValueButtonHeight)
        lineView!.frame = CGRectMake(0, snY, self.bounds.size.width, 3.0)
        
        inputDrawingView?.cutCurrentValuesToMax(Double(ay))
        
        self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
    }
    
    func maxButtonUp(buttn: UIButton, event: UIEvent) {
        self.sendActionsForControlEvents(UIControlEvents.EditingDidEnd)
    }
    
    func inputCurrentValuesChanged() {
        self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
        setLevelViewPositions(inputDrawingView!.dMax, yMin: inputDrawingView!.yMin)
    }
    
    func inputCurrentValuesFinishedChanging() {
        self.sendActionsForControlEvents(UIControlEvents.EditingDidEnd)
    }
    
    func setLevelViewPositions(valMax: Double, yMin: Double) {
        maxValueButton?.setTitle(String(format:"%.3f", valMax), forState: UIControlState.Normal)
        maxValueButton!.frame = CGRectMake(self.bounds.size.width - MaxValueButtonWidth, CGFloat(yMin) - MaxValueButtonHeight, MaxValueButtonWidth, MaxValueButtonHeight)
        lineView!.frame = CGRectMake(0, CGFloat(yMin), self.bounds.size.width, 3.0)
    }
}
