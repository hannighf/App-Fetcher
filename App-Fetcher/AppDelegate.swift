//
//  AppDelegate.swift
//  App-Fetcher
//
//  Created by hannighf on 2021.
//

//特定のアプリケーションウィンドウをメニューバーアイコンの下(任意の位置)に持ってきます。マルチディスプレイだったり
//同じアプリケーションで複数のウィンドウが存在していても、特定のウィンドウをメニューバーアイコンの下(任意の位置)に持ってきます。

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
    var Point: CGPoint!
    var Size: CGSize!
    
    var preferencesWindowController : NSWindowController?
    var advancePoint = false
    var advanceSize = false
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String : true]
        let accessEnabled = AXIsProcessTrustedWithOptions(options)
        if !accessEnabled {
            print("Access Not Enabled")
        }
        
        button = statusItem.button!
        button.title = "App-Fetcher"
        button.image = NSImage(named:NSImage.Name("hand"))
        button.action = #selector(clicked(_:))
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])


        menu.addItem(NSMenuItem(title: "SET APP", action: #selector(setWindow(_:)), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Preferences", action: #selector(preferences(_:)), keyEquivalent: ""))
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
            dispWindow()
        
        default:
            break
        }
    }

    @objc func setWindow(_ sender: NSStatusBarButton) {
        print("set_window")
        app = NSWorkspace.shared.frontmostApplication

        if let wrappedName = app.localizedName {
            itemTitle.title = wrappedName
//            itemTitle.action = #selector(fetchWindow(_:))
        }
        
        let _axuiElm = AXUIElementCreateApplication(app.processIdentifier);
        var value: AnyObject?
        let error = AXUIElementCopyAttributeValue(_axuiElm, kAXWindowsAttribute as CFString, &value)
        let axuiElmList = value as? [AXUIElement]
        axuiElm = axuiElmList?.first

        if axuiElm != nil {
            //current point
//            var _point = CGPoint.zero
//            var valPoint: CFTypeRef?
//            AXUIElementCopyAttributeValue(axuiElm, kAXPositionAttribute as CFString, &valPoint)
//            AXValueGetValue(valPoint! as! AXValue, AXValueType.cgPoint, &_point)
//            Point = _point
//            print(_point)
            
            var valSize: CFTypeRef?
            var _size = CGSize.zero
            AXUIElementCopyAttributeValue(axuiElm, kAXSizeAttribute as CFString, &valSize)
            AXValueGetValue(valSize! as! AXValue, AXValueType.cgSize, &_size)
            Size = _size
            print(_size)
        }
    }

    
    @objc func preferences(_ sender: NSStatusBarButton) {
        print("settings")
        
        //create window instance
        if (preferencesWindowController == nil) {
            let storyboard = NSStoryboard(name: "Main", bundle: nil)
            preferencesWindowController = storyboard.instantiateController(withIdentifier: "PrefsWindow") as? NSWindowController
        }
        //display window to front
        if (preferencesWindowController != nil) {
            NSApp.activate(ignoringOtherApps: true)
            preferencesWindowController!.showWindow(sender)
        }
    }
    

    @objc func resetWindow(_ sender: NSStatusBarButton) {
        print("reset_window")
        app = nil
        itemTitle.title = "None"
//        itemTitle.action = nil
        axuiElm = nil
        Point = nil
        Size = nil
    }
    
    @objc func fetchWindow(_ sender: NSStatusBarButton) {
        print("fetch_window")
        dispWindow()

    }
    
    func dispWindow() {
        print("display_window")
        if axuiElm != nil {
            var position : CFTypeRef
            var size : CFTypeRef
            var newPoint = CGEvent(source: nil)!.location
            var newSize = Size
            
            if advancePoint {
                newPoint = CGPoint(x: 900 , y: 0)
            }
            if advanceSize {
                newSize = CGSize(width: 300, height: 300)
            }

            position = AXValueCreate(AXValueType(rawValue: kAXValueCGPointType)!,&newPoint)!;
            AXUIElementSetAttributeValue(axuiElm, kAXPositionAttribute as CFString, position);

            size = AXValueCreate(AXValueType(rawValue: kAXValueCGSizeType)!,&newSize)!;
            AXUIElementSetAttributeValue(axuiElm, kAXSizeAttribute as CFString, size);
            
            let rect = AXValueCreate(AXValueType(rawValue: kAXValueCGRectType)!,&newSize)!;
            let range = AXValueCreate(AXValueType(rawValue: kAXValueCFRangeType)!,&newSize)!;
            print(rect)
            print(range)

            app?.activate(options: .activateIgnoringOtherApps)
        }
    }

}
