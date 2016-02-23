//
//  SettingsChooserCustomHeader.swift
//  Izhikevich
//
//  Created by Colin Prepscius on 5/24/15.
//  Copyright (c) 2015 Infinite State Machine Inc. All rights reserved.
//

import UIKit


protocol SettingsChooserCustomHeaderDelegate {
    func addNewPressedForHeader(header: SettingsChooserCustomHeader)
}

class SettingsChooserCustomHeader: UITableViewHeaderFooterView {

    var delegate: SettingsChooserCustomHeaderDelegate?
    
    @IBAction func addNewPressed(sender: AnyObject) {
        delegate?.addNewPressedForHeader(self)
    }
}
