//
//  SimulationViewController.swift
//  Izhikevich
//
//  Created by Colin Prepscius on 5/8/15.
//  Copyright (c) 2015 Infinite State Machine Inc. All rights reserved.
//

import UIKit

func prec(k: Double, z: Double) -> Double {
    return Double(Int(Double(k) * z)) / z
}

class ParametersScrollView: UIScrollView {
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        let hitView = subviews[0].hitTest(point, withEvent: event)
        let v = hitView == subviews[0] ? self : hitView
        return v
    }
}

protocol SimulationViewControllerDelegate {
    func toggleSettingsChooser()
}

class SimulationViewController : UIViewController {

    @IBOutlet var scrollView: UIScrollView?
    
    @IBOutlet var toggleListButton: UIButton?
    @IBOutlet var titleLabel: UILabel?
    @IBOutlet var titleEditField: UITextField?
    @IBOutlet var parametersLabel: UILabel?

    @IBOutlet weak var vGraph: GraphRenderView?
    @IBOutlet weak var uGraph: GraphRenderView?
    @IBOutlet weak var phasePortrait: PhasePortrait?
    @IBOutlet weak var inputCurrentView: InputCurrentCreationView?
    
    @IBOutlet weak var aSlider: FancyNumberSlider?
    @IBOutlet weak var bSlider: FancyNumberSlider?
    @IBOutlet weak var cSlider: FancyNumberSlider?
    @IBOutlet weak var dSlider: FancyNumberSlider?
    @IBOutlet weak var v0Slider: FancyNumberSlider?
    
    @IBOutlet weak var aValueLabel: UILabel?
    @IBOutlet weak var bValueLabel: UILabel?
    @IBOutlet weak var cValueLabel: UILabel?
    @IBOutlet weak var dValueLabel: UILabel?
    @IBOutlet weak var v0ValueLabel: UILabel?
 
    @IBOutlet weak var vMaxLabel: UILabel?
    @IBOutlet weak var vMinLabel: UILabel?
    @IBOutlet weak var uMaxLabel: UILabel?
    @IBOutlet weak var uMinLabel: UILabel?
    
    @IBOutlet weak var currentTimeView1: UIView?
    @IBOutlet weak var currentTimeView2: UIView?
    @IBOutlet weak var currentTimeView3: UIView?
    
    @IBOutlet weak var clearButton: UIButton?
    @IBOutlet weak var saveButton: UIButton?
    
    @IBOutlet weak var drawHereLabel: UILabel?
    
    
    var popoverController: UIPopoverController?
    
    var delegate: SimulationViewControllerDelegate?
    
    var simulationSettingsCoreData: SimulationSettingsCoreData?
    var simulationSettings: SimulationSettings?

    
    func renderV(simulationOutput: SimulationOutput) {
        vGraph?.setNewData(simulationOutput.v!, newMinY: simulationOutput.vMin, newMaxY: simulationOutput.vMax)
        vGraph?.setNeedsDisplay()
        vMaxLabel?.text = String(format:"%.3f", simulationOutput.vMax)
        vMinLabel?.text = String(format:"%.3f", simulationOutput.vMin)
    }
    
    func renderU(simulationOutput: SimulationOutput) {
        uGraph?.setNewData(simulationOutput.u!, newMinY: simulationOutput.uMin, newMaxY: simulationOutput.uMax)
        uGraph?.setNeedsDisplay()
        uMaxLabel?.text = String(format:"%.3f", simulationOutput.uMax)
        uMinLabel?.text = String(format:"%.3f", simulationOutput.uMin)
    }
    
    func renderPhasePortrait(simulationOutput: SimulationOutput) {
        if let s = simulationSettings {
            phasePortrait?.setNewSimulationSettings(s)
            phasePortrait?.setNewData(simulationOutput)
            phasePortrait?.setNeedsDisplay()
        }
    }
    
    func generateAndRender() {
        if let s = simulationSettings {
            let simulationOutput = runSimulation(s)
            renderV(simulationOutput)
            renderU(simulationOutput)
            renderPhasePortrait(simulationOutput)
            
            parametersLabel?.attributedText = simulationSettings!.parametersString()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView!.contentSize = CGSize(width: scrollView!.bounds.size.width, height: scrollView!.bounds.size.height + 580)
    }
    
    func hideDrawHereLabel() {
        UIView.animateWithDuration(5.0) { () -> Void in
            self.drawHereLabel?.alpha = 0
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if NSUserDefaults.standardUserDefaults().boolForKey("drawherehidden") {
            hideDrawHereLabel()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    @IBAction func settingsChooserTapped(sender: AnyObject) {
        delegate?.toggleSettingsChooser()
        if toggleListButton?.titleLabel!.text == "⇝" {
            toggleListButton?.setTitle("⇜", forState: UIControlState.Normal)
        } else {
            toggleListButton?.setTitle("⇝", forState: UIControlState.Normal)
        }
    }
    
    @IBAction func titleLabelTapped(sender: UIButton) {
        if self.simulationSettingsCoreData!.isPreset.boolValue == false {
            titleEditField!.text = self.simulationSettingsCoreData!.name
            titleEditField!.hidden = false
            titleEditField!.becomeFirstResponder()
        }
    }
    
    @IBAction func titleEditFieldChanged(sender: AnyObject) {
        self.simulationSettingsCoreData!.name = titleEditField!.text!
        sharedAppDelegate().saveContext()
        titleEditField!.resignFirstResponder()
        titleEditField!.hidden = true
        titleLabel!.text = self.simulationSettingsCoreData!.name
    }
    
    @IBAction func sliderChanged(sender: FancyNumberSlider) {
        if let s = simulationSettings {
            saveButton!.enabled = true
            switch sender.tag {
            case 0:
                s.a = prec(sender.value, z:1000.0)
                aValueLabel!.text = "\(s.a)"
            case 1:
                s.b = prec(sender.value, z:100.0)
                bValueLabel!.text = "\(s.b)"
            case 2:
                s.c = prec(sender.value, z:10.0)
                cValueLabel!.text = "\(s.c)"
            case 3:
                s.d = prec(sender.value, z:100.0)
                dValueLabel!.text = "\(s.d)"
            case 4:
                s.v0 = prec(sender.value, z:1.0)
                v0ValueLabel!.text = "\(s.v0)"
            default:
                NSLog("WHAT!!!")
            }
            generateAndRender()
        }
    }
    
    @IBAction func sliderFinishedChanging(sender: UISlider) {

    }
    
    @IBAction func inputCurrentValuesChanged(sender: InputCurrentCreationView) {
        simulationSettings?.input = sender.getCurrentValues()
        generateAndRender()
    }
    
    @IBAction func inputcurrentValuesFinishedChanging(sender: InputCurrentCreationView) {
        saveButton!.enabled = true
        phasePortrait?.setNewInputVector((simulationSettings?.input)!)
        phasePortrait?.setNeedsDisplay()
        
        if drawHereLabel!.alpha > 0 {
            hideDrawHereLabel()
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "drawherehidden")
        }
    }
    
    @IBAction func sendSpikesButtonPressed(sender: UIButton) {
        if let s = simulationSettings {
            saveButton!.enabled = true
            let simulationOutput = runSimulation(s)
            var spikesOnly = simulationOutput.v?.map({ (v: Double) -> Double in
                return v > 20.0 ? 10.0 : 0.0
            })
            var i = 0
            for i=1; i<spikesOnly!.count; i++ {
                if spikesOnly![i] == 10.0 && spikesOnly![i-1] == 10.0 {
                    spikesOnly![i-1] = 0.0
                }
            }
            s.input = spikesOnly!
            inputCurrentView?.setCurrentValues(spikesOnly!)
            inputCurrentView?.setNeedsDisplay()
            inputCurrentView?.inputDrawingView?.setNeedsDisplay()
            phasePortrait?.setNewInputVector((simulationSettings?.input)!)
            phasePortrait?.setNeedsDisplay()
            generateAndRender()
        }
    }
    
    @IBAction func clearButtonPressed(sender: UIButton) {
        clearButton!.hidden = true
        aSlider!.showHomeValue = false
        bSlider!.showHomeValue = false
        cSlider!.showHomeValue = false
        dSlider!.showHomeValue = false
        v0Slider!.showHomeValue = false
    }
    
    @IBAction func timeSliderDragged(sender: UISlider) {
        let t = min(999, Int(sender.value * 1000.0))
        let inputVoltage = self.inputCurrentView!.getCurrentValues()[t]
        phasePortrait?.inputVoltage = inputVoltage
        phasePortrait?.currentTimestep = t
        phasePortrait?.setNeedsDisplay()
        
        let x = vGraph!.frame.origin.x + vGraph!.frame.size.width * CGFloat(t) / 1000.0
        currentTimeView1?.center = CGPoint(x: x, y: currentTimeView1!.center.y)
        currentTimeView2?.center = CGPoint(x: x, y: currentTimeView2!.center.y)
        currentTimeView3?.center = CGPoint(x: x, y: currentTimeView3!.center.y)
    }
    
    @IBAction func timeSliderStarted(sender: UISlider) {
        currentTimeView1?.hidden = false
        currentTimeView2?.hidden = false
        currentTimeView3?.hidden = false
    }
    
    @IBAction func timeSliderFinished(sender: UISlider) {
        currentTimeView1?.hidden = true
        currentTimeView2?.hidden = true
        currentTimeView3?.hidden = true
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "selectParametersPopoverSegue" {
            let p = segue as! UIStoryboardPopoverSegue
            popoverController = p.popoverController
            let c = popoverController!.contentViewController as! ParametersChooserViewController
            c.delegate = self
        } else if segue.identifier == "saveSimulationPopoverSegue" {
            let p = segue as! UIStoryboardPopoverSegue
            popoverController = p.popoverController
            let saveVC = popoverController!.contentViewController as! SaveViewController
            saveVC.delegate = self
            saveVC.simulationSettingsCoreData = self.simulationSettingsCoreData!
            saveVC.simulationSettings = self.simulationSettings!
        }
    }
}


extension SimulationViewController: SettingsChooserViewControllerDelegate {
    
    func settingsSelected(settings_: SimulationSettingsCoreData) {
        
        saveButton!.enabled = false

        self.simulationSettingsCoreData = settings_
        self.simulationSettings = SimulationSettings(fromCoreData: settings_)
        
        self.titleLabel!.text = self.simulationSettingsCoreData!.name
        
        self.inputCurrentView?.setCurrentValues(self.simulationSettings!.input)
        self.inputCurrentView?.setNeedsDisplay()
        self.inputCurrentView?.inputDrawingView?.setNeedsDisplay()
        
        phasePortrait?.setNewInputVector((simulationSettings?.input)!)
        phasePortrait?.setNeedsDisplay()

        aSlider!.value = simulationSettings!.a
        bSlider!.value = simulationSettings!.b
        cSlider!.value = simulationSettings!.c
        dSlider!.value = simulationSettings!.d
        v0Slider!.value = simulationSettings!.v0
        
        aValueLabel!.text = "\(simulationSettings!.a)"
        bValueLabel!.text = "\(simulationSettings!.b)"
        cValueLabel!.text = "\(simulationSettings!.c)"
        dValueLabel!.text = "\(simulationSettings!.d)"
        v0ValueLabel!.text = "\(simulationSettings!.v0)"
        
        generateAndRender()
    }
}

extension SimulationViewController : ParametersChooserViewControllerDelegate {
    
    func parametersChosen(parameters: SimulationSettingsCoreData) {
        
        saveButton!.enabled = true

        popoverController?.dismissPopoverAnimated(true)
        popoverController = nil
        
        aSlider!.setValue(Double(parameters.a), animated:true)
        bSlider!.setValue(Double(parameters.b), animated:true)
        cSlider!.setValue(Double(parameters.c), animated:true)
        dSlider!.setValue(Double(parameters.d), animated:true)
        v0Slider!.setValue(Double(parameters.v0), animated:true)
        
        aValueLabel!.text = "\(parameters.a)"
        bValueLabel!.text = "\(parameters.b)"
        cValueLabel!.text = "\(parameters.c)"
        dValueLabel!.text = "\(parameters.d)"
        v0ValueLabel!.text = "\(parameters.v0)"
        
        aSlider!.showHomeValue = true
        aSlider!.homeValue = aSlider!.value
        
        bSlider!.showHomeValue = true
        bSlider!.homeValue = bSlider!.value
        
        cSlider!.showHomeValue = true
        cSlider!.homeValue = cSlider!.value
        
        dSlider!.showHomeValue = true
        dSlider!.homeValue = dSlider!.value
        
        v0Slider!.showHomeValue = true
        v0Slider!.homeValue = v0Slider!.value
        
        simulationSettings!.copyParametersOnlyFromCoreData(parameters)
        
        generateAndRender()
        
        clearButton!.hidden = false
    }
}

extension SimulationViewController : SaveViewControllerDelegate {
    
    func saveViewController(saveViewController: SaveViewController, didSaveSettings: SimulationSettingsCoreData) {
        simulationSettingsCoreData = didSaveSettings
        self.titleLabel!.text = self.simulationSettingsCoreData!.name
        popoverController?.dismissPopoverAnimated(true)
        popoverController = nil
        saveButton!.enabled = false
    }
}

extension SimulationViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
