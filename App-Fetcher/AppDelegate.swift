//
//  AppDelegate.swift
//  App-Fetcher
//
//  Created by hannighf on 2021/11/08.
//

import Cocoa
import Quartz

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    var button: NSStatusBarButton!
    let menu = NSMenu()
    let menuItem = NSMenuItem()

    var app: NSRunningApplication!
    var itemTitle: NSMenuItem!
    var axuiElm: AXUIElement!
    var point: CGPoint!
    var size: CGSize!
    
    var useManualPoint = false
    var useManualSize = false
    
    var viewController: ViewController!
    var preferencesWindowController : NSWindowController?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String : true]
        let accessEnabled = AXIsProcessTrustedWithOptions(options)
//        if !accessEnabled {
//            print("Access Not Enabled")
//        }
        button = statusItem.button!
        button.title = "App-Fetcher"
        button.image = NSImage(named:NSImage.Name("hand"))
        button.action = #selector(clicked(_:))
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        menu.addItem(NSMenuItem(title: "SET APP", action: #selector(setWindow(_:)), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Preferences", action: #selector(OpenPreferences(_:)), keyEquivalent: ""))
        itemTitle = NSMenuItem(title: "None", action: nil, keyEquivalent: "")
        menu.addItem(itemTitle)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: ""))
    }

    @objc func clicked(_ sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!
        switch event.type {
        case .rightMouseUp:
            statusItem.menu = menu
            statusItem.button?.performClick(nil)
            statusItem.menu = nil

        case .leftMouseUp:
            displayWindow()
        
        default:
            break
        }
    }

    @objc func setWindow(_ sender: NSStatusBarButton) {
        app = NSWorkspace.shared.frontmostApplication

        if let wrappedName = app.localizedName {
            itemTitle.title = wrappedName
        }
        
        let _axuiElm = AXUIElementCreateApplication(app.processIdentifier);
        var value: AnyObject?
        let error = AXUIElementCopyAttributeValue(_axuiElm, kAXWindowsAttribute as CFString, &value)
        if (error == .success) {
            let axuiElmList = value as? [AXUIElement]
            axuiElm = axuiElmList?.first
        }

        if axuiElm != nil {
            size = getSize()
        }
    }
    
    @objc func OpenPreferences(_ sender: NSStatusBarButton) {
        if (preferencesWindowController == nil) {
            let storyboard = NSStoryboard(name: "Main", bundle: nil)
            preferencesWindowController = storyboard.instantiateController(withIdentifier: "PrefsWindow") as? NSWindowController
        }

        if (preferencesWindowController != nil) {
            NSApp.activate(ignoringOtherApps: true)
            preferencesWindowController!.showWindow(sender)
        }
    }
    
    @objc func resetWindow(_ sender: NSStatusBarButton) {
        app = nil
        itemTitle.title = "None"
        axuiElm = nil
        point = nil
        size = nil
    }
    
    @objc func fetchWindow(_ sender: NSStatusBarButton) {
        displayWindow()
    }
    
    func displayWindow() {
        if axuiElm != nil {
            var CFSize : CFTypeRef
            var CFPoint : CFTypeRef

            var newSize : CGSize!
            if viewController != nil {
                if viewController.useCostomSize.state != .on {
                    newSize = getSize()
                } else {
                    newSize = CGSize(width: CGFloat(viewController.width.intValue), height: CGFloat(viewController.height.intValue))
                }
            } else {
                newSize = getSize()
            }
                        
            var newPoint : CGPoint!
            if viewController != nil {
                if viewController.useCostomPoint.state != .on {
                    let clickedPoint = getPoint()
                    newPoint = CGPoint(x: clickedPoint.x - newSize.width/2, y: clickedPoint.y)
                } else {
                    newPoint = CGPoint(x: CGFloat(viewController.x.intValue), y: CGFloat(viewController.y.intValue))
                }
            } else {
                let clickedPoint = getPoint()
                newPoint = CGPoint(x: clickedPoint.x - newSize.width/2, y: clickedPoint.y)
            }

            CFSize = AXValueCreate(AXValueType(rawValue: kAXValueCGSizeType)!,&newSize)!;
            AXUIElementSetAttributeValue(axuiElm, kAXSizeAttribute as CFString, CFSize);
            
            CFPoint = AXValueCreate(AXValueType(rawValue: kAXValueCGPointType)!,&newPoint)!;
            AXUIElementSetAttributeValue(axuiElm, kAXPositionAttribute as CFString, CFPoint);

            app?.activate(options: .activateIgnoringOtherApps)
        }
    }
    
    func getSize() -> CGSize {
        var valSize: CFTypeRef?
        var size = CGSize.zero
        AXUIElementCopyAttributeValue(axuiElm, kAXSizeAttribute as CFString, &valSize)
        AXValueGetValue(valSize! as! AXValue, AXValueType.cgSize, &size)
        return size
    }
    
    func getPoint() -> CGPoint {
        return CGEvent(source: nil)!.location
    }

}
