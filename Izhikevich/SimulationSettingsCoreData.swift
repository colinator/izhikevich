//
//  SimulationSettingsCoreData.swift
//  Izhikevich
//
//  Created by Colin Prepscius on 5/30/15.
//  Copyright (c) 2015 Infinite State Machine Inc. All rights reserved.
//

import Foundation
import CoreData

class SimulationSettingsCoreData: NSManagedObject {

    @NSManaged var a: NSNumber
    @NSManaged var b: NSNumber
    @NSManaged var c: NSNumber
    @NSManaged var d: NSNumber
    @NSManaged var input: NSData?
    @NSManaged var isPreset: NSNumber
    @NSManaged var name: String
    @NSManaged var v0: NSNumber

}
