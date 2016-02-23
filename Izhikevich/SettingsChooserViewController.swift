//
//  SettingsChooserViewController.swift
//  Izhikevich
//
//  Created by Colin Prepscius on 5/23/15.
//  Copyright (c) 2015 Infinite State Machine Inc. All rights reserved.
//

import UIKit
import CoreData


class SettingsListCell: UITableViewCell {
    
    @IBOutlet var nameLabel: UILabel?
    @IBOutlet var outputView: GraphRenderView?
    @IBOutlet var inputCurrentView: GraphRenderView?
    @IBOutlet var settingsLabel: UILabel?
    
    var settings: SimulationSettingsCoreData?
    
    func displaySettings(settings_: SimulationSettingsCoreData) {
        
        settings = settings_
        
        nameLabel!.text = settings_.name
        
        let simulationSettings = SimulationSettings(fromCoreData: settings_)
        let simulationOutput = runSimulation(simulationSettings)

        settingsLabel?.attributedText = simulationSettings.parametersString()

        outputView?.setNewData(simulationOutput.v!, newMinY: simulationOutput.vMin, newMaxY: simulationOutput.vMax)
        outputView?.setNeedsDisplay()
        
        inputCurrentView?.setNewData(simulationSettings.input, newMinY: simulationOutput.iMin, newMaxY: simulationOutput.iMax)
        inputCurrentView?.setNeedsDisplay()
    }
}


protocol SettingsChooserViewControllerDelegate {
    func settingsSelected(settings: SimulationSettingsCoreData)
}


class SettingsChooserViewController: UITableViewController {

    var settingsChooserDelegate: SettingsChooserViewControllerDelegate?
    var selectedSimulation: SimulationSettingsCoreData?

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
        
        frc.delegate = self
        
        return frc
        }()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.registerNib(UINib(nibName:"SettingsChooserCustomHeader", bundle:nil), forHeaderFooterViewReuseIdentifier:"SettingsChooserCustomHeader")
        self.tableView.registerNib(UINib(nibName:"SettingsChooserPresetHeader", bundle:nil), forHeaderFooterViewReuseIdentifier:"SettingsChooserPresetHeader")
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("An error occurred")
        }
    }
    
    func hasCustomSimulations() -> Bool {
        return fetchedResultsController.sections!.count == 2
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if self.tableView(self.tableView, numberOfRowsInSection: 0) > 0 {
            if let s = selectedSimulation {
                if let selectedIndexPath = fetchedResultsController.indexPathForObject(s) {
                    if hasCustomSimulations() {
                        self.tableView.selectRowAtIndexPath(selectedIndexPath, animated: false, scrollPosition: .Middle)
                    } else {
                        let newIndexPath = NSIndexPath(forRow: selectedIndexPath.row, inSection: 1)
                        self.tableView.selectRowAtIndexPath(newIndexPath, animated: false, scrollPosition: .Middle)
                    }
                }
            } else {
                self.tableView.selectRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), animated: false, scrollPosition: UITableViewScrollPosition.Top)
            }
        }
    }


    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var n = 0
        if let sections = fetchedResultsController.sections {
            if sections.count == 1 && section == 0 {
                n = 1
            } else {
                let currentSection = sections[sections.count == 1 ? 0 : section] 
                n = currentSection.numberOfObjects
            }
        }
        return max(n, 1)
    }

    func configureCustomCell(cell: SettingsListCell, settings: SimulationSettingsCoreData) {
        cell.displaySettings(settings)
    }
 
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let noCustom = fetchedResultsController.sections!.count == 1
        let isDegenerateCustom = indexPath.section == 0 && noCustom
        if !isDegenerateCustom {
            let nIndexPath = NSIndexPath(forRow: indexPath.row, inSection: noCustom ? 0 : indexPath.section)
            let settings = self.fetchedResultsController.objectAtIndexPath(nIndexPath) as! SimulationSettingsCoreData
            self.configureCustomCell(cell as! SettingsListCell, settings: settings)
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 && fetchedResultsController.sections!.count == 1 {
            return tableView.dequeueReusableCellWithIdentifier("SettingsNoSimulationsListCell", forIndexPath: indexPath) 
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("SettingsListCell", forIndexPath: indexPath) 
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let v = tableView.dequeueReusableHeaderFooterViewWithIdentifier("SettingsChooserCustomHeader") as? SettingsChooserCustomHeader
            v?.delegate = self
            return v
        } else {
            return tableView.dequeueReusableHeaderFooterViewWithIdentifier("SettingsChooserPresetHeader")! as UITableViewHeaderFooterView
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let c = self.fetchedResultsController.sections!.count
        if !(c == 1 && indexPath.section == 0) {
            let nIndexPath = NSIndexPath(forRow: indexPath.row, inSection: c == 1 ? 0 : indexPath.section)
            let settings = self.fetchedResultsController.objectAtIndexPath(nIndexPath) as! SimulationSettingsCoreData
            settingsChooserDelegate?.settingsSelected(settings)
        }
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        let n = fetchedResultsController.sections![0].numberOfObjects
        return indexPath.section == 0 && n > 0
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete") { (action, indexPath) -> Void in
            let settings = self.fetchedResultsController.objectAtIndexPath(indexPath) as! SimulationSettingsCoreData
            sharedAppDelegate().managedObjectContext!.deleteObject(settings)
            sharedAppDelegate().saveContext()
        }
        deleteAction.backgroundColor = UIColor.redColor()
        return [ deleteAction ]
    }
}

extension SettingsChooserViewController : NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject object: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            if newIndexPath!.section == 0 && newIndexPath!.row == 0 {
                self.tableView.reloadData()
            } else {
                self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
            }
        case .Update:
            let cell = self.tableView.cellForRowAtIndexPath(indexPath!)
            if cell != nil {
                self.configureCell(cell!, atIndexPath: indexPath!)
                self.tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
            }
        case .Move:
            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
            self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
        case .Delete:
            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
}

extension SettingsChooserViewController : SettingsChooserCustomHeaderDelegate {
    
    func addNewPressedForHeader(header: SettingsChooserCustomHeader) {
        
        // create a new simulation
        let entity =  NSEntityDescription.entityForName("SimulationSettingsCoreData", inManagedObjectContext:sharedAppDelegate().managedObjectContext!)
        let newSettings = SimulationSettingsCoreData(entity: entity!, insertIntoManagedObjectContext:sharedAppDelegate().managedObjectContext)
        newSettings.name = "custom simulation"
        newSettings.isPreset = false
        sharedAppDelegate().saveContext()
    }
}
