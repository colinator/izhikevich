//
//  AppDelegate.swift
//  Izhikevich
//
//  Created by Colin Prepscius on 5/8/15.
//  Copyright (c) 2015 Infinite State Machine Inc. All rights reserved.
//

import UIKit
import CoreData


func documentsDirectory() -> NSString {
    let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
    return paths[0] as String
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    // cuz it's cool to render them.
    func createAppIcons() {
        
        let x1 = 0.0
        let y1 = 6.0
        let yh = 45.0
        let yd = -5.0
        let y2 = 10.0
        
        let w = 76.0
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: w, height: w))
        view.clipsToBounds = true
        
        let g1 = GraphRenderView(frame: CGRect(x: x1, y: y1, width: w - (2 * x1), height: yh))
        let g2y = Double(g1.frame.origin.y + g1.frame.size.height + CGFloat(yd))
        let g2 = GraphRenderView(frame: CGRect(x: x1, y: g2y, width: w - (2 * x1), height: w - g2y - y2))
        
        view.addSubview(g1)
        view.addSubview(g2)
        
        view.backgroundColor = UIColor.whiteColor()
        
        let simulationSettings = SimulationSettings(a: 0.06, b: 0.2, c: -65.0, d: 0.6, v0: -70.0, input: createWaveInput(Int(g2.frame.size.width), baseValue: 0.0, startCurveAt: 10, curveLength: Int(g2.frame.size.width) - 20, maxValue: 10.0))
        let simulationOutput = runSimulation(simulationSettings)
        
        g1.setNewData(simulationOutput.v!, newMinY: simulationOutput.vMin, newMaxY: simulationOutput.vMax)
        g1.setNeedsDisplay()
        
        g2.setNewData(simulationSettings.input, newMinY: simulationOutput.iMin, newMaxY: simulationOutput.iMax)
        g2.setNeedsDisplay()
        
        g1.backgroundColor = UIColor.clearColor()
        g2.backgroundColor = UIColor.clearColor()

        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
        view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        
        let filePath = documentsDirectory().stringByAppendingPathComponent("appicon@2x.png")
        NSLog("FILEPATH: \(filePath)")
        
        if let data = UIImagePNGRepresentation(img) {
            data.writeToFile(filePath, atomically: true)
        }
    }
    
    func createConstantInput(startAtTime: Int, numSteps: Int, value: Double) -> [Double] {
        let a1 = Array<Double>(count: startAtTime, repeatedValue: 0.0)
        let a2 = Array<Double>(count: numSteps - startAtTime, repeatedValue: value)
        return a1 + a2
    }
    
    func createLinearInput(startAtTime: Int, numSteps: Int, maxValue: Double) -> [Double] {
        let a1 = Array<Double>(count: startAtTime, repeatedValue: 0.0)
        var k = 0
        let a2 = Array<Double>(count: numSteps - startAtTime, repeatedValue: 0).map({ (d: Double) -> Double in k = k + 1; return maxValue * Double(k) / Double(numSteps - startAtTime) })
        return a1 + a2
    }
    
    func createDivotedInput(numSteps: Int, baseValue: Double, divots: (Int, Int, Double)... ) -> [Double] {
        var a = Array<Double>(count: numSteps, repeatedValue: baseValue)
        for (s, n, v) in divots {
            var i = 0
            for i = s; i < (s+n); ++i {
                a[i] = v
            }
        }
        return a
    }
    
    func createRampedInput(numSteps: Int, baseValue: Double, ramps: (Int, Int, Double)... ) -> [Double] {
        var a = Array<Double>(count: numSteps, repeatedValue: baseValue)
        for (s, n, v) in ramps {
            var i = 0
            for i = s; i < (s+n); ++i {
                a[i] = v * Double(i-s) / Double(n)
            }
        }
        return a
    }
    
    func createWaveInput(numSteps: Int, baseValue: Double, startCurveAt: Int, curveLength: Int, maxValue: Double) -> [Double] {
        var a = Array<Double>(count: numSteps, repeatedValue: baseValue)
        var i = 0
        for i = startCurveAt; i<(startCurveAt + curveLength); i++ {
            let x = Double(i - startCurveAt) / Double(curveLength) * 2 * M_PI - M_PI_2
            let y = (sin(x) * 0.5 + 0.5) * maxValue
            a[i] = y
        }
        return a
    }

    func createPresetSettings(isPreset: Bool, name: String, a: Double, b: Double, c: Double, d: Double, v0: Double, input: [Double]) {
        let entity =  NSEntityDescription.entityForName("SimulationSettingsCoreData", inManagedObjectContext: self.managedObjectContext!)
        let newSettings = SimulationSettingsCoreData(entity: entity!, insertIntoManagedObjectContext:self.managedObjectContext)
        newSettings.name = name
        newSettings.a = a
        newSettings.b = b
        newSettings.c = c
        newSettings.d = d
        newSettings.v0 = v0
        newSettings.isPreset = isPreset
        newSettings.input = NSKeyedArchiver.archivedDataWithRootObject(input)
    }

    func createPresetSettings(name: String, a: Double, b: Double, c: Double, d: Double, v0: Double, input: [Double]) {
        createPresetSettings(true, name: name, a: a, b: b, c: c, d: d, v0: v0, input: input)
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // get the current number of drawings; create the first if there are none
        let count = mocCount(self.managedObjectContext!, entityName: "SimulationSettingsCoreData")
        if count == 0 {
            
            createPresetSettings(false, name: "simulation 1", a: 0.06, b: 0.2, c: -65.0, d: 6.0, v0: -70.0, input: createWaveInput(1000, baseValue: 0.0, startCurveAt: 250, curveLength: 500, maxValue: 8.0))
//            createPresetSettings(false, name: "simulation aaa", a: 0.06, b: 0.2, c: -65.0, d: 6.0, v0: -70.0, input: createWaveInput(1000, baseValue: 0.0, startCurveAt: 10, curveLength: 56, maxValue: 10.0))
           
           
            createPresetSettings("(A) tonic spiking", a: 0.02, b: 0.2, c: -65.0, d: 6.0, v0: -70.0, input: createConstantInput(100, numSteps: 1000, value: 14.0))
            createPresetSettings("(B) phasic spiking", a: 0.02, b: 0.25, c: -65.0, d: 6.0, v0: -64.0, input: createConstantInput(100, numSteps: 1000, value: 0.5))
            createPresetSettings("(C) tonic bursting", a: 0.02, b: 0.2, c: -50.0, d: 2.0, v0: -70.0, input: createConstantInput(100, numSteps: 1000, value: 15.0))
            createPresetSettings("(D) phasic bursting", a: 0.02, b: 0.25, c: -55.0, d: 0.05, v0: -64.0, input: createConstantInput(100, numSteps: 1000, value: 0.6))
            createPresetSettings("(E) mixed mode", a: 0.02, b: 0.2, c: -55.0, d: 4.0, v0: -70.0, input: createConstantInput(100, numSteps: 1000, value: 10.0))
            createPresetSettings("(F) spike frequency adaptation", a: 0.01, b: 0.2, c: -65.0, d: 8.0, v0: -70.0,
                input: createConstantInput(100, numSteps: 1000, value: 30.0))
            createPresetSettings("(G) Class 1 excitable", a: 0.02, b: 0.22, c: -55.0, d: 6.0, v0: -60.0, input: createLinearInput(100, numSteps: 1000, maxValue: 10.0))
            createPresetSettings("(H) Class 2 excitable", a: 0.2, b: 0.26, c: -65.0, d: 0.0, v0: -64.0, input: createLinearInput(100, numSteps: 1000, maxValue: 10.0))
            createPresetSettings("(I) spike latency", a: 0.02, b: 0.2, c: -65.0, d: 6.0, v0: -70.0, input: createDivotedInput(1000, baseValue: 0.0, divots: (100, 3, 7.04)))
            createPresetSettings("(J) subthreshhold oscillations", a: 0.05, b: 0.26, c: -60.0, d: 0.0, v0: -62.0, input: createDivotedInput(1000, baseValue: 0.0, divots: (100, 4, 2.0)))
            createPresetSettings("(K) resonator (cannot replicate!)", a: 0.1, b: 0.26, c: -60.0, d: -1.0, v0: -62.0, input: createDivotedInput(1000, baseValue: 0.0, divots: (100, 15, 0.65), (120, 15, 0.65), (400, 15, 0.65), (440, 15, 0.65)))
            createPresetSettings("(L) integrator", a: 0.2, b: 0.24, c: -50.0, d: 6.0, v0: -70.0, input: createDivotedInput(1000, baseValue: 0.0, divots: (100, 1, 9.0), (105, 1, 9.0), (400, 1, 9.0), (410, 1, 9.0)))
            createPresetSettings("(M) rebound spike", a: 0.14, b: 0.26, c: -50.0, d: 3.0, v0: -61.0, input: createDivotedInput(1000, baseValue: 0.0, divots: (100, 4, -15.0)))
            createPresetSettings("(N) rebound burst", a: 0.06, b: 0.26, c: -52.0, d: 0.0, v0: -63.0, input: createDivotedInput(1000, baseValue: 0.0, divots: (100, 4, -15.0)))
            createPresetSettings("(O) threshhold variability", a: 0.03, b: 0.25, c: -60.0, d: 4.0, v0: -64.0, input: createDivotedInput(1000, baseValue: 0.0, divots: (110, 5, 1.0), (270, 5, -6.0), (280, 5, 1.0)))
            createPresetSettings("(P) bistability", a: 0.1, b: 0.26, c: -57.8, d: 0.0, v0: -61.0, input: createDivotedInput(1000, baseValue: 0.24, divots: (110, 5, 1.24), (589, 5, 1.24)))
            createPresetSettings("(Q) depolarizing after-potential", a: 0.75, b: 0.2, c: -60.0, d: -21.0, v0: -70.0, input: createDivotedInput(1000, baseValue: 0.0, divots: (500, 1, 20.0)))
            createPresetSettings("(R) accomodation (cannot replicate!)", a: 0.0, b: 0.19, c: -60.0, d: 2.8, v0: -72.0, input: createRampedInput(1000, baseValue: 0, ramps: (100, 200, 8.0), (400, 12, 4.0)))
            createPresetSettings("(S) inhibition-induced spiking", a: -0.02, b: -1.0, c: -60.0, d: 8.0, v0: -63.8, input: createDivotedInput(1000, baseValue: 80.0, divots: (200, 600, 75.0)))
            createPresetSettings("(T) inhibition-induced bursting", a: -0.03, b: -1.0, c: -43.0, d: 1.0, v0: -63.8, input: createDivotedInput(1000, baseValue: 80.0, divots: (200, 600, 75.0)))
            self.saveContext()
        }
        
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        let containerViewController = SlideOutListAndDetailViewController()
        
        window!.rootViewController = containerViewController
        window!.makeKeyAndVisible()
        
        
        // createAppIcons()

        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    

    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.xxxx.ProjectName" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] 
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("IzhikevichDataModel", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("Izhikevich.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch var error1 as NSError {
            error = error1
            coordinator = nil
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        } catch {
            fatalError()
        }
        
        return coordinator
        }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges {
                do {
                    try moc.save()
                } catch let error1 as NSError {
                    error = error1
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog("Unresolved error \(error), \(error!.userInfo)")
                    abort()
                }
            }
        }
    }
}

func sharedAppDelegate() -> AppDelegate {
    return UIApplication.sharedApplication().delegate as! AppDelegate
}

