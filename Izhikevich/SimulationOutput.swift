//
//  SimulationOutput.swift
//  Izhikevich
//
//  Created by Colin Prepscius on 7/11/15.
//  Copyright (c) 2015 Infinite State Machine Inc. All rights reserved.
//

import Foundation

class SimulationOutput {
    
    var vMin: Double = 1000000.0
    var vMax: Double = -1000000.0
    var uMin: Double = 1000000.0
    var uMax: Double = -1000000.0
    var iMin: Double = 1000000.0
    var iMax: Double = -1000000.0
    var v: Array<Double>?
    var u: Array<Double>?
    
    var hasData : Bool {
        get {
            return v != nil && u != nil
        }
    }
    
    var count: Int {
        get {
            if let kv = v {
                return kv.count
            }
            return 0
        }
    }
    
    var vDiff: Double {
        return vMax - vMin
    }
    
    var uDiff: Double {
        return uMax - uMin
    }
}
