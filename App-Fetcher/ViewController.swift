//
//  ViewController.swift
//  App-Fetcher
//
//  Created by hannighf on 2021/11/08.
//

import Cocoa
import AppKit

class ViewController: NSViewController {
    
    @IBOutlet weak var x: NSTextField!
    @IBOutlet weak var y: NSTextField!
    @IBOutlet weak var width: NSTextField!
    @IBOutlet weak var height: NSTextField!
    @IBOutlet weak var useCostomPoint: NSButton!
    @IBOutlet weak var useCostomSize: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate:AppDelegate = NSApplication.shared.delegate as! AppDelegate
        appDelegate.viewController = self
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func pointCheckBoxClicked(_ sender: Any) {
        if useCostomPoint.state != .on {
            x.isEnabled = false
            y.isEnabled = false
        } else {
            x.isEnabled = true
            y.isEnabled = true
        }
    }
    
    @IBAction func sizeCheckBoxClicked(_ sender: Any) {
        if useCostomSize.state != .on {
            width.isEnabled = false
            height.isEnabled = false
        } else {
            width.isEnabled = true
            height.isEnabled = true
        }
    }
}

