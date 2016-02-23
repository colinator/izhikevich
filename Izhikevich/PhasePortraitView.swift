//
//  PhasePortraitView.swift
//  Izhikevich
//
//  Created by Colin Prepscius on 7/8/15.
//  Copyright (c) 2015 Infinite State Machine Inc. All rights reserved.
//

import UIKit


let xmin = CGFloat(-90.0)   // simulationOutput!.vMin
let xdiff = CGFloat(125.0)  // simulationOutput!.vDiff
let ymin = CGFloat(-20.0)   // simulationOutput!.uMin
let ydiff = CGFloat(30.0)   // simulationOutput!.uDiff


class PhaseCoordinateSystemView: UIView {
    
    func virtualPointToPhysicalPoint(p: CGPoint) -> CGPoint {
        let x = (p.x - xmin) / xdiff * self.bounds.size.width
        let y = self.bounds.size.height - CGFloat((p.y - ymin) / ydiff) * self.bounds.size.height
        return CGPoint(x: x, y: y)
    }
}

class UNullSpaceBaseView: PhaseCoordinateSystemView {
    
    func drawVNullParabola(i: Double, color: UIColor, strokeWidth: CGFloat) {
        let vNullPath = UIBezierPath()
        var x = Double(xmin)
        let y = 0.04 * x * x + 5.0 * x + 140.0 + i
        vNullPath.moveToPoint(virtualPointToPhysicalPoint(CGPoint(x: x, y:y)))
        while x < 0.0 {
            let y = 0.04 * x * x + 5.0 * x + 140.0 + i
            let p = virtualPointToPhysicalPoint(CGPoint(x: x, y: y))
            vNullPath.addLineToPoint(p)
            x += 1.0
        }
        color.setStroke()
        vNullPath.lineWidth = strokeWidth
        vNullPath.stroke()
    }
}

class UNullSpaceView: UNullSpaceBaseView {
    var inputVector: [Double]? = nil

    
    func setNewInputVector(iVector: [Double]) {
        self.inputVector = iVector
    }
    
    override func drawRect(rect: CGRect) {
        if let i = inputVector {
            for d in i {
                drawVNullParabola(d, color: UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.05), strokeWidth: 1.0)
            }
        }
    }
}

class PhasePortraitView: UNullSpaceBaseView {

    var simulationSettings: SimulationSettings?
    var simulationOutput: SimulationOutput?
    var inputVoltage: Double = 0
    
    func setNewSimulationSettings(simulationSettings: SimulationSettings) {
        self.simulationSettings = simulationSettings
    }
    
    func setNewData(simulationOutput: SimulationOutput) {
        self.simulationOutput = simulationOutput
    }

    private func pointAt(index: Int) -> CGPoint {
        let v = simulationOutput!.v![index]
        let u = simulationOutput!.u![index]
        return virtualPointToPhysicalPoint(CGPoint(x: v, y: u))
    }
    
    private func drawVNull() {
        drawVNullParabola(inputVoltage, color: UIColor(red: 0, green: 1.0, blue: 0, alpha: 1.0), strokeWidth: 2.0)
    }
    
    private func drawUNull() {
        let uNullPath = UIBezierPath()
        
        let x0 = Double(xmin)
        let x1 = Double(xmin + xdiff)
        
        let b = simulationSettings!.b
        let p0 = CGPoint(x: x0, y: b * x0)
        let p1 = CGPoint(x: x1, y: b * x1)
        
        uNullPath.moveToPoint(virtualPointToPhysicalPoint(p0))
        uNullPath.addLineToPoint(virtualPointToPhysicalPoint(p1))
        
        UIColor(red: 1.0, green: 0, blue: 0, alpha: 1.0).setStroke()
        uNullPath.lineWidth = 2.0
        uNullPath.stroke()
    }
    
    private func drawPointAt(p: CGPoint) {
        let r = 4.0 / self.contentScaleFactor
        let path = UIBezierPath(arcCenter: p, radius: r, startAngle: 0, endAngle: CGFloat(M_PI * 2.0), clockwise: true)
        UIColor(red: 0, green: 0, blue: 1, alpha: 0.5).setFill()
        UIColor(red: 0, green: 0, blue: 1, alpha: 0.5).setStroke()
        path.lineWidth = 1.0 / self.contentScaleFactor
        //path.fill()
        path.stroke()
    }
    
    private func drawLineFrom(p1: CGPoint, to p2: CGPoint) {
        let path = UIBezierPath()
        path.moveToPoint(p1)
        path.addLineToPoint(p2)
        UIColor(red: 0, green: 0.5, blue: 1, alpha: 0.2).setStroke()
        path.lineWidth = 1.0 / self.contentScaleFactor
        path.stroke()
    }

    override func drawRect(rect: CGRect) {
        
        // draw the null-clines
        if simulationSettings != nil {
            drawVNull()
            drawUNull()
        }
        
        // draw the phase progress
        if self.simulationOutput != nil {
            
            var i = 0
            var p = pointAt(i)
      
            drawPointAt(p)
            
            for i = 1; i < simulationOutput!.count; ++i {
                let pn = pointAt(i)
                drawLineFrom(p, to: pn)
                drawPointAt(pn)
                p = pn
            }
        }
    }
}

class PhasePortraitCurrentIndicatorView: PhaseCoordinateSystemView {
    
    var currentPointsArray: [CGPoint]? = nil
    
    override func drawRect(rect: CGRect) {
        
        if let cp = currentPointsArray {
            
            var alpha = CGFloat(1.0)
            
            for vp in cp {
                
                let p = virtualPointToPhysicalPoint(vp)
                
                let r = 8.0 / self.contentScaleFactor
                let path = UIBezierPath(arcCenter: p, radius: r, startAngle: 0, endAngle: CGFloat(M_PI * 2.0), clockwise: true)
                UIColor(red: 1, green: 0, blue: 1, alpha: alpha).setFill()
                UIColor(red: 1, green: 0, blue: 1, alpha: alpha).setStroke()
                path.lineWidth = 2.0 / self.contentScaleFactor
                path.fill()
                path.stroke()
                
                alpha = alpha / 2.0
                
            }
        }
    }
}

class PhasePortraitTotalView: UIView {
    
    var unullspaceView: UNullSpaceView
    var phasePortraitView: PhasePortraitView
    var phasePortraitCurrentIndicatorView: PhasePortraitCurrentIndicatorView
    
    var inputVoltage: Double {
        set(newInputVoltage) {
            phasePortraitView.inputVoltage = newInputVoltage
            phasePortraitView.setNeedsDisplay()
        }
        get {
            return phasePortraitView.inputVoltage
        }
    }
    
    var currentTimestep: Int = 0 {
        didSet(newCurrentTimestep) {
            let v = phasePortraitView.simulationOutput!.v![newCurrentTimestep]
            let u = phasePortraitView.simulationOutput!.u![newCurrentTimestep]
            phasePortraitCurrentIndicatorView.currentPointsArray = [ CGPoint(x: v, y: u)]
            phasePortraitCurrentIndicatorView.setNeedsDisplay()
        }
    }

    override init(frame: CGRect) {
        unullspaceView = UNullSpaceView(frame: frame)
        phasePortraitView = PhasePortraitView(frame: frame)
        phasePortraitCurrentIndicatorView = PhasePortraitCurrentIndicatorView(frame: frame)
        super.init(frame: frame)
        unullspaceView.frame = self.bounds
        phasePortraitView.frame = self.bounds
        phasePortraitCurrentIndicatorView.frame = self.bounds
        self.addSubview(unullspaceView)
        self.addSubview(phasePortraitView)
        self.addSubview(phasePortraitCurrentIndicatorView)
        phasePortraitView.backgroundColor = UIColor.clearColor()
        phasePortraitCurrentIndicatorView.backgroundColor = UIColor.clearColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        unullspaceView = UNullSpaceView(coder: aDecoder)!
        phasePortraitView = PhasePortraitView(coder: aDecoder)!
        phasePortraitCurrentIndicatorView = PhasePortraitCurrentIndicatorView(coder: aDecoder)!
        super.init(coder: aDecoder)
        unullspaceView.frame = self.bounds
        phasePortraitView.frame = self.bounds
        phasePortraitCurrentIndicatorView.frame = self.bounds
        self.addSubview(unullspaceView)
        self.addSubview(phasePortraitView)
        self.addSubview(phasePortraitCurrentIndicatorView)
        phasePortraitView.backgroundColor = UIColor.clearColor()
        phasePortraitCurrentIndicatorView.backgroundColor = UIColor.clearColor()
    }
    
    func setNewInputVector(iVector: [Double]) {
        self.unullspaceView.setNewInputVector(iVector)
        self.unullspaceView.setNeedsDisplay()
    }

    func setNewSimulationSettings(simulationSettings: SimulationSettings) {
        self.phasePortraitView.setNewSimulationSettings(simulationSettings)
        self.phasePortraitView.setNeedsDisplay()
    }
    
    func setNewData(simulationOutput: SimulationOutput) {
        self.phasePortraitView.setNewData(simulationOutput)
        self.phasePortraitView.setNeedsDisplay()
    }
}

class PhasePortrait: UIScrollView {
    
    var phasePortraitTotalView: PhasePortraitTotalView
    
    var inputVoltage: Double {
        set(newInputVoltage) {
            phasePortraitTotalView.inputVoltage = newInputVoltage
        }
        get {
            return phasePortraitTotalView.inputVoltage
        }
    }
    
    var currentTimestep: Int {
        set(newCurrentTimestap) {
            phasePortraitTotalView.currentTimestep = newCurrentTimestap
        }
        get {
            return phasePortraitTotalView.currentTimestep
        }
    }

    override init(frame: CGRect) {
        phasePortraitTotalView = PhasePortraitTotalView(frame: frame)
        super.init(frame: frame)
        phasePortraitTotalView.frame = self.bounds
        phasePortraitTotalView.contentMode = .Redraw
        self.addSubview(phasePortraitTotalView)
        self.minimumZoomScale = 1.0
        self.maximumZoomScale = 10.0
        self.delegate = self
        self.clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        phasePortraitTotalView = PhasePortraitTotalView(coder: aDecoder)!
        super.init(coder: aDecoder)
        phasePortraitTotalView.frame = self.bounds
        phasePortraitTotalView.contentMode = .Redraw
        self.addSubview(phasePortraitTotalView)
        self.minimumZoomScale = 1.0
        self.maximumZoomScale = 10.0
        self.delegate = self
        self.clipsToBounds = true
    }
    
    func setNewInputVector(iVector: [Double]) {
        phasePortraitTotalView.setNewInputVector(iVector)
    }
    
    func setNewSimulationSettings(simulationSettings: SimulationSettings) {
        phasePortraitTotalView.setNewSimulationSettings(simulationSettings)
    }
    
    func setNewData(simulationOutput: SimulationOutput) {
        phasePortraitTotalView.setNewData(simulationOutput)
    }
}

extension PhasePortrait : UIScrollViewDelegate {
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return phasePortraitTotalView
    }
    
    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?, atScale scale: CGFloat) {
        phasePortraitTotalView.layer.contents = nil
        phasePortraitTotalView.contentScaleFactor = scale
        phasePortraitTotalView.phasePortraitView.contentScaleFactor = scale
        phasePortraitTotalView.phasePortraitCurrentIndicatorView.contentScaleFactor = scale
        phasePortraitTotalView.phasePortraitView.setNeedsDisplay()
        phasePortraitTotalView.phasePortraitCurrentIndicatorView.setNeedsDisplay()
    }
}
