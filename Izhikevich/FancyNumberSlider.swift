//
//  FancyNumberSlider.swift
//  Izhikevich
//
//  Created by Colin Prepscius on 6/1/15.
//  Copyright (c) 2015 Infinite State Machine Inc. All rights reserved.
//

import UIKit

let OffTargetColor = UIColor(red: 0, green: 0.5, blue: 1.0, alpha: 0.5)
let OnTargetColor = UIColor(red: 0, green: 0.5, blue: 1.0, alpha: 1.0)

func valueRounded(v: Double, numDecimalPlaces: Int) -> Double {
    let k = pow(10.0, Double(numDecimalPlaces))
    return Double(Int(v * k)) / k
}


class HomeTargetView : UIView {
    
    var color: UIColor = OnTargetColor {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override func drawRect(rect: CGRect) {
        let CircleRadus: CGFloat = 15.0
        let linePath = UIBezierPath()
        let x : CGFloat = self.bounds.size.width / 2.0
        linePath.moveToPoint(CGPoint(x:x, y:0))
        linePath.addLineToPoint(CGPoint(x:x, y:self.bounds.size.height/2 - CircleRadus))
        linePath.addArcWithCenter(self.center, radius: CircleRadus, startAngle: CGFloat(-M_PI_2), endAngle: CGFloat(2 * M_PI - M_PI_2), clockwise: false)
        linePath.moveToPoint(CGPoint(x:x, y:self.bounds.size.height/2 + CircleRadus))
        linePath.addLineToPoint(CGPoint(x:x, y:self.bounds.size.height))
        self.color.setStroke()
        linePath.lineWidth = 2.0
        linePath.stroke()
    }
}

class HomeIndicatorView : UIView {
    
    var homeTargetView: HomeTargetView!
    var homeNumberLabel: UILabel!
    
    var showAlignment: Bool = true {
        didSet {
            let color = showAlignment ? OnTargetColor : OffTargetColor
            homeTargetView.color = color
            homeNumberLabel.textColor = color
        }
    }

    var text: String? {
        get {
            return homeNumberLabel.text
        }
        set {
            homeNumberLabel.text = newValue
            positionLabel()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createUI()
    }

    func createUI() {
        homeTargetView = HomeTargetView(frame: CGRectZero)
        homeTargetView.backgroundColor = UIColor.clearColor()
        self.addSubview(homeTargetView)
        homeNumberLabel = UILabel(frame: CGRectZero)
        homeNumberLabel.backgroundColor = UIColor.clearColor()
        homeNumberLabel.font = UIFont.boldSystemFontOfSize(13.0)
        self.addSubview(homeNumberLabel)
    }
    
    func positionLabel() {
        homeNumberLabel.sizeToFit()
        homeNumberLabel.center = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height + homeNumberLabel.bounds.size.height/2)
    }
    
    override func layoutSubviews() {
        homeTargetView.frame = self.bounds
        positionLabel()
    }
}

class FancyNumberSlider: UIControl {

    var slider: UISlider!
    var homeIndicator: HomeIndicatorView!
    var decimalPlaces: Int = 2
    
    func xPositionFromValue(v: Double) -> CGFloat {
        let c = slider.thumbRectForBounds(slider.bounds, trackRect: slider.trackRectForBounds(slider.bounds), value: Float(v))
        return c.origin.x + c.size.width / 2.0
    }
    
    var homeValue: Double = 0 {
        didSet {
            homeIndicator.center = CGPoint(x: xPositionFromValue(homeValue), y: self.bounds.size.height/2.0)
            homeIndicator.text = "\(homeValue)"
            homeIndicator.showAlignment = theValue == homeValue
        }
    }
    
    var showHomeValue: Bool = false {
        didSet {
            homeIndicator.hidden = !showHomeValue
            homeIndicator.showAlignment = theValue == homeValue
        }
    }
    
    var max: Float {
        get {
            return slider.maximumValue
        }
        set {
            slider.maximumValue = newValue
        }
    }
    
    var min: Float {
        get {
            return slider.minimumValue
        }
        set {
            slider.minimumValue = newValue
        }
    }

    var theValue: Double = 0
    var value: Double {
        get {
            return theValue
        }
        set {
            theValue = valueRounded(newValue, numDecimalPlaces: decimalPlaces)
            homeIndicator.showAlignment = theValue == homeValue
            slider.value = Float(theValue)
        }
    }
    
    func setValue(value: Double, animated: Bool) {
        theValue = valueRounded(value, numDecimalPlaces: decimalPlaces)
        homeIndicator.showAlignment = theValue == homeValue
        slider.setValue(Float(theValue), animated: animated)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createUI()
    }
    
    func createUI() {
        self.clipsToBounds = false
        slider = UISlider(frame: CGRectZero)
        slider.addTarget(self, action: "sliderValueChanged:", forControlEvents: .ValueChanged)
        self.addSubview(slider)
        homeIndicator = HomeIndicatorView(frame: CGRectZero)
        homeIndicator.userInteractionEnabled = false
        homeIndicator.backgroundColor = UIColor.clearColor()
        homeIndicator.hidden = !showHomeValue
        self.homeValue = 0.5
        self.addSubview(homeIndicator)
    }

    override func layoutSubviews() {
        slider.frame = self.bounds
        homeIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: self.bounds.size.height)
        homeIndicator.center = CGPoint(x: xPositionFromValue(self.homeValue), y: self.bounds.size.height/2.0)
    }
    
    func sliderValueChanged(s: UISlider) {
        self.value = Double(s.value)
        self.sendActionsForControlEvents(.ValueChanged)
    }
}
