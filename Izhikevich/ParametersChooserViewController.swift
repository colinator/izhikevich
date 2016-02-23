//
//  ParametersChooserViewController.swift
//  Izhikevich
//
//  Created by Colin Prepscius on 5/31/15.
//  Copyright (c) 2015 Infinite State Machine Inc. All rights reserved.
//

import UIKit
import CoreData

class ParametersListCell : UITableViewCell {
    
    @IBOutlet var nameLabel: UILabel?
    @IBOutlet var parametersLabel: UILabel?
    @IBOutlet var outputView: GraphRenderView?
    @IBOutlet var inputCurrentView: GraphRenderView?
    
    func displaySettings(settings_: SimulationSettingsCoreData) {
        
        let simulationSettings = SimulationSettings(fromCoreData: settings_)
        let simulationOutput = runSimulation(simulationSettings)
        
        nameLabel!.text = settings_.name
        parametersLabel?.attributedText = simulationSettings.parametersString(15)
        
        outputView?.setNewData(simulationOutput.v!, newMinY: simulationOutput.vMin, newMaxY: simulationOutput.vMax)
        outputView?.setNeedsDisplay()
        
        inputCurrentView?.setNewData(simulationSettings.input, newMinY: simulationOutput.iMin, newMaxY: simulationOutput.iMax)
        inputCurrentView?.setNeedsDisplay()
    }
}

protocol ParametersChooserViewControllerDelegate {
    func parametersChosen(parameters: SimulationSettingsCoreData)
}

class ParametersChooserViewController: UITableViewController {

     var delegate: ParametersChooserViewControllerDelegate?
    
     lazy var fetchedResultsController: NSFetchedResultsController = {
        let drawingsFetchRequest = NSFetchRequest(entityName: "SimulationSettingsCoreData")
        let primarySortDescriptor = NSSortDescriptor(key: "isPreset", ascending: true)
        let secondarySortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        drawingsFetchRequest.sortDescriptors = [primarySortDescriptor, secondarySortDescriptor]
        
        let frc = NSFetchedResultsController(
            fetchRequest: drawingsFetchRequest,
            managedObjectContext: sharedAppDelegate().managedObjectContext!,
            sectionNameKeyPath: "isPreset",
            cacheName: nil)
        
        return frc
        }()

    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("An error occurred")
        }
    }

    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections!.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fetchedResultsController.sections![section].numberOfObjects
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ParametersListCell", forIndexPath: indexPath) as! ParametersListCell
        let settings = self.fetchedResultsController.objectAtIndexPath(indexPath) as! SimulationSettingsCoreData
        cell.displaySettings(settings)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let settings = self.fetchedResultsController.objectAtIndexPath(indexPath) as! SimulationSettingsCoreData
        delegate?.parametersChosen(settings)
        self.popoverPresentationController
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let o: SimulationSettingsCoreData = self.fetchedResultsController.sections![section].objects![0] as! SimulationSettingsCoreData
        return o.isPreset.boolValue ? "Preset Settings" : "Custom Settings"
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 64))
        v.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.9)
        let l = UILabel(frame: CGRect(x: 20, y: 35, width: tableView.bounds.size.width - 40, height: 21))
        let o: SimulationSettingsCoreData = self.fetchedResultsController.sections![section].objects![0] as! SimulationSettingsCoreData
        l.text = o.isPreset.boolValue ? "Preset Settings" : "Custom Settings"
        l.font = UIFont.boldSystemFontOfSize(17)
        l.textColor = UIColor.whiteColor()
        v.addSubview(l)
        return v
    }
}
