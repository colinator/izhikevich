//
//  SimulationSettings.swift
//  Izhikevich
//
//  Created by Colin Prepscius on 2/15/16.
//  Copyright © 2016 Infinite State Machine Inc. All rights reserved.
//

import Foundation
import UIKit

class SimulationSettings {
    
    var a: Double = 0
    var b: Double = 0
    var c: Double = 0
    var d: Double = 0
    var v0: Double = 0
    var input: [Double] = [Double](count: 1000, repeatedValue: 0.0)
    
    init(a: Double, b: Double, c: Double, d: Double, v0: Double, input: [Double]) {
        self.a = a
        self.b = b
        self.c = c
        self.d = d
        self.v0 = v0
        self.input = input
    }
    
    init(fromCoreData: SimulationSettingsCoreData) {
        self.a = fromCoreData.a.doubleValue
        self.b = fromCoreData.b.doubleValue
        self.c = fromCoreData.c.doubleValue
        self.d = fromCoreData.d.doubleValue
        self.v0 = fromCoreData.v0.doubleValue
        self.input = fromCoreData.input == nil ?
            [Double](count: 1000, repeatedValue: 0.0) :
            (NSKeyedUnarchiver.unarchiveObjectWithData(fromCoreData.input!) as! [Double])
    }
    
    func copyParametersOnlyFromCoreData(fromSim: SimulationSettingsCoreData) {
        a = fromSim.a.doubleValue
        b = fromSim.b.doubleValue
        c = fromSim.c.doubleValue
        d = fromSim.d.doubleValue
        v0 = fromSim.v0.doubleValue
    }
    
    func copyToCoreData(toCoreData: SimulationSettingsCoreData) {
        toCoreData.a = NSNumber(double: a)
        toCoreData.b = NSNumber(double: b)
        toCoreData.c = NSNumber(double: c)
        toCoreData.d = NSNumber(double: d)
        toCoreData.v0 = NSNumber(double: v0)
        toCoreData.input = NSKeyedArchiver.archivedDataWithRootObject(input)
    }
    
    func parametersString(fontSize: CGFloat = 13) -> NSAttributedString {
        
        let font1: UIFont? = UIFont.boldSystemFontOfSize(fontSize)
        let font2: UIFont? = UIFont.systemFontOfSize(fontSize)
        
        let parametersString = NSMutableAttributedString(string: "")
        
        let aString = NSAttributedString( string: "a: ", attributes: [ NSFontAttributeName : font1! ])
        let aVString = NSAttributedString( string: "\(Float(a))  ", attributes: [ NSFontAttributeName : font2! ])
        let bString = NSAttributedString( string: "b: ", attributes: [ NSFontAttributeName : font1! ])
        let bVString = NSAttributedString( string: "\(Float(b))  ", attributes: [ NSFontAttributeName : font2! ])
        let cString = NSAttributedString( string: "c: ", attributes: [ NSFontAttributeName : font1! ])
        let cVString = NSAttributedString( string: "\(Float(c))  ", attributes: [ NSFontAttributeName : font2! ])
        let dString = NSAttributedString( string: "d: ", attributes: [ NSFontAttributeName : font1! ])
        let dVString = NSAttributedString( string: "\(Float(d))  ", attributes: [ NSFontAttributeName : font2! ])
        
        parametersString.appendAttributedString(aString)
        parametersString.appendAttributedString(aVString)
        parametersString.appendAttributedString(bString)
        parametersString.appendAttributedString(bVString)
        parametersString.appendAttributedString(cString)
        parametersString.appendAttributedString(cVString)
        parametersString.appendAttributedString(dString)
        parametersString.appendAttributedString(dVString)
        
        return parametersString
    }

}
