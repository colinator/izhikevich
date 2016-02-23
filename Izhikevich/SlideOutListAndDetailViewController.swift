//
//  SlideOutListAndDetailViewController.swift
//  SuperClass
//
//  Created by Colin Prepscius on 5/10/15.
//  Copyright (c) 2015 Colin Prepscius. All rights reserved.
//

import UIKit
import CoreData

class SlideOutListAndDetailViewController: UIViewController {

    var settingsChooserViewController: SettingsChooserViewController?
    var simulationViewController: SimulationViewController!
    
    var currentlyExpanded: Bool = false

    let centerPanelExpansionDistance: CGFloat = 320

    override func viewDidLoad() {
        super.viewDidLoad()
        
        simulationViewController = UIStoryboard.simulationViewController()
        simulationViewController.delegate = self
        view.addSubview(simulationViewController.view)
        addChildViewController(simulationViewController)
        simulationViewController.didMoveToParentViewController(self)
        
        let settingsFetchRequest = NSFetchRequest(entityName: "SimulationSettingsCoreData")
        let primarySortDescriptor = NSSortDescriptor(key: "isPreset", ascending: true)
        let secondarySortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        settingsFetchRequest.fetchLimit = 1
        settingsFetchRequest.sortDescriptors = [primarySortDescriptor, secondarySortDescriptor]
        
        let settings: [AnyObject]?
        do {
            settings = try sharedAppDelegate().managedObjectContext?.executeFetchRequest(settingsFetchRequest)
        } catch {
            settings = nil
        }
        if settings?.count > 0 {
            let firstSettings = settings?[0] as! SimulationSettingsCoreData
            simulationViewController.settingsSelected(firstSettings)
        }
    }
}


extension SlideOutListAndDetailViewController: SimulationViewControllerDelegate {
    
    func toggleSettingsChooser() {
        if !currentlyExpanded {
            addLeftPanelViewController()
        }
        animateLeftPanel(shouldExpand: !currentlyExpanded)
    }
    
    func addLeftPanelViewController() {
        if (settingsChooserViewController == nil) {
            settingsChooserViewController = UIStoryboard.settingsChooserViewController()
            settingsChooserViewController!.settingsChooserDelegate = simulationViewController
            settingsChooserViewController!.view.frame = CGRect(x: 0, y: 0, width: centerPanelExpansionDistance, height: self.view.bounds.size.height)
            view.insertSubview(settingsChooserViewController!.view, atIndex: 0)
            addChildViewController(settingsChooserViewController!)
            settingsChooserViewController!.didMoveToParentViewController(self)
            settingsChooserViewController!.selectedSimulation = self.simulationViewController.simulationSettingsCoreData!
        }
    }

    func animateLeftPanel(shouldExpand shouldExpand: Bool) {
        if (shouldExpand) {
            currentlyExpanded = true
            self.simulationViewController.view.layer.shadowColor = UIColor.grayColor().CGColor
            self.simulationViewController.view.layer.shadowRadius = 2.0
            self.simulationViewController.view.layer.shadowOpacity = 0.5
            animateCenterPanelXPosition(targetPosition: centerPanelExpansionDistance)
        } else {
            self.simulationViewController.view.layer.shadowColor = nil
            self.simulationViewController.view.layer.shadowRadius = 0
            self.simulationViewController.view.layer.shadowOpacity = 0
            animateCenterPanelXPosition(targetPosition: 0) { finished in
                self.currentlyExpanded = false
                self.settingsChooserViewController!.view.removeFromSuperview()
                self.settingsChooserViewController = nil;
            }
        }
    }
    
    func animateCenterPanelXPosition(targetPosition targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
            self.simulationViewController.view.frame.origin.x = targetPosition
            }, completion: completion)
    }
}

private extension UIStoryboard {
    
    class func mainStoryboard() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()) }
    
    class func settingsChooserViewController() -> SettingsChooserViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("SettingsChooserViewController") as? SettingsChooserViewController
    }
    
    class func simulationViewController() -> SimulationViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("SimulationViewController") as? SimulationViewController
    }
}
