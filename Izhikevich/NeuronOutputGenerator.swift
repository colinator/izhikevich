//
//  NeuronOutputGenerator.swift
//  Izhikevich
//
//  Created by Colin Prepscius on 5/24/15.
//  Copyright (c) 2015 Infinite State Machine Inc. All rights reserved.
//

import Foundation

func runSimulation(settings: SimulationSettings) -> (SimulationOutput) {
    
    let output : SimulationOutput = SimulationOutput()
    
    let a: Double = settings.a
    let b: Double = settings.b
    let c: Double = settings.c
    let d: Double = settings.d
    let input: [Double] = settings.input
    
    var v = settings.v0
    var u = b * v
    var vN : Double
    var uN : Double
    
    var I = 0.0
    
    output.v = [Double](count: input.count, repeatedValue: 0.0)
    output.u = [Double](count: input.count, repeatedValue: 0.0)
    
    var t: Int
    for t = 0; t < input.count; ++t {
        
        I = input[t]
        
        vN = v + 0.04 * v * v + 5.0 * v + 140.0 - u + I
        // Not sure if this is correct (the vN bit below - could be v instead),
        // but that's how Izhi's matlab samples are written
        uN = u + a * (b * vN - u)
        //uN = u + a * (b * v - u)
        
        if vN >= 30.0 {
            vN = c
            uN = u + d
            output.v![t] = 30
        } else {
            output.v![t] = vN
        }
        
        output.u![t] = uN
        
        v = vN
        u = uN
        
        if I > output.iMax {
            output.iMax = I
        }
        if I < output.iMin {
            output.iMin = I
        }
        if v > output.vMax {
            output.vMax = v
        }
        if v < output.vMin {
            output.vMin = v
        }
        if u > output.uMax {
            output.uMax = u
        }
        if u < output.uMin {
            output.uMin = u
        }
        
        output.vMax = 30.0
    }
    
    if output.vMin == output.vMax {
        output.vMin = -70.0
        output.vMax = 30.0
    }
    if output.uMin == output.uMax {
        output.uMin = 0.0
        output.uMax = 1.0
    }
    
    return output
}
