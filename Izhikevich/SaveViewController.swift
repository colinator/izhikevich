//
//  SaveViewController.swift
//  Izhikevich
//
//  Created by Colin Prepscius on 2/14/16.
//  Copyright © 2016 Infinite State Machine Inc. All rights reserved.
//

import UIKit
import CoreData


protocol SaveViewControllerDelegate: class {
    func saveViewController(saveViewController: SaveViewController, didSaveSettings: SimulationSettingsCoreData)
}

class SaveViewController: UIViewController {

    @IBOutlet var explanationLabel: UILabel?
    @IBOutlet var textField: UITextField?
    @IBOutlet var saveButton: UIButton?
    
    weak var delegate: SaveViewControllerDelegate? = nil
    var simulationSettingsCoreData: SimulationSettingsCoreData? = nil
    var simulationSettings: SimulationSettings? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField?.text = simulationSettingsCoreData!.name
        if ((simulationSettingsCoreData!.isPreset.boolValue) == true) {
            explanationLabel?.text = "You cannot save over a preset simulation. If you want to make a copy, just change the name."
            saveButton!.enabled = false
            saveButton!.setTitle("Save Copy", forState: .Normal)
        } else {
            explanationLabel?.text = "If you want to make a copy of this simulation, just change the name."
            saveButton!.enabled = true
            saveButton!.setTitle("Save", forState: .Normal)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func saveButtonPressed(button: UIButton) {
        if (textField!.text! != simulationSettingsCoreData!.name) {
            let entity =  NSEntityDescription.entityForName("SimulationSettingsCoreData", inManagedObjectContext: sharedAppDelegate().managedObjectContext!)
            simulationSettingsCoreData = SimulationSettingsCoreData(entity: entity!, insertIntoManagedObjectContext:sharedAppDelegate().managedObjectContext)
            simulationSettingsCoreData!.isPreset = false
        }
        simulationSettings!.copyToCoreData(simulationSettingsCoreData!)
        simulationSettingsCoreData!.name = textField!.text!
        sharedAppDelegate().saveContext()
        delegate?.saveViewController(self, didSaveSettings: simulationSettingsCoreData!)
    }
    
    @IBAction func textValueChanged(field: UITextField) {
        if let name = field.text {
            if ((simulationSettingsCoreData!.isPreset.boolValue) == true) {
                if name == simulationSettingsCoreData!.name {
                    saveButton!.enabled = false
                } else {
                    saveButton!.enabled = true
                }
            } else {
                if name == simulationSettingsCoreData!.name {
                    saveButton!.setTitle("Save", forState: .Normal)
                } else {
                    saveButton!.setTitle("Save Copy", forState: .Normal)
                }
            }
        }
    }
}
