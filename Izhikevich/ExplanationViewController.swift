//
//  ExplanationViewController.swift
//  Izhikevich
//
//  Created by Colin Prepscius on 2/12/16.
//  Copyright © 2016 Infinite State Machine Inc. All rights reserved.
//

import UIKit

class ExplanationViewController: UIViewController {

    @IBOutlet var htmlView: UIWebView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let explanationUrl = NSBundle.mainBundle().URLForResource("whatisthis", withExtension: "html")
        htmlView?.loadRequest(NSURLRequest(URL: explanationUrl!))
    }
}
