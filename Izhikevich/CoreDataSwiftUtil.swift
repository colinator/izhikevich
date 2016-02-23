//
//  CoreDataSwiftUtil.swift
//  SuperClass
//
//  Created by Colin Prepscius on 5/15/15.
//  Copyright (c) 2015 Colin Prepscius. All rights reserved.
//

import Foundation
import CoreData

func mocCount(managedObjectContext: NSManagedObjectContext, entityName: String) -> Int {
    let request = NSFetchRequest(entityName: entityName)
    request.includesSubentities = false
    var error: NSError?
    let count: Int = managedObjectContext.countForFetchRequest(request, error: &error)
    return count
}