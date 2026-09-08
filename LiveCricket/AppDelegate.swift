//
//  AppDelegate.swift
//  LiveCricket
//
//  Created by Abhi Reddy on 11/03/2023.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    private var statusItem: NSStatusItem!
    let popover = NSPopover()

    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "cricket.ball", accessibilityDescription: "1")
            button.action = #selector(AppDelegate.togglePopover(_:))
        }
        
        self.popover.contentViewController = ViewController.newInstance()
        self.popover.animates = false
        
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    @objc func togglePopover(_ sender: NSStatusItem) {
        if self.popover.isShown {
            closePopover(sender: sender)
        }
        else {
            showPopover(sender: sender)
        }
    }
    
    func showPopover(sender: Any?) {
        if let button = self.statusItem.button {
            self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
         }
    }

    func closePopover(sender: Any?)  {
        self.popover.performClose(sender)
    }
    
}

