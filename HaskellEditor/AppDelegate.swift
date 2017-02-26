//
//  AppDelegate.swift
//  macGHCi
//
//  Created by Daniel Strebinger on 20.02.17.
//  Copyright © 2017 Daniel Strebinger. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification)
    {
        if (!FileManager.default.fileExists(atPath: "/usr/local/bin/ghci")) {
            let alert : NSAlert = NSAlert()
            alert.messageText = "Could not locate the ghci module at path /usr/local/bin/ghci"
            alert.informativeText = "In order to use this program please visit the https://www.haskell.org/downloads to download and install their latest ghc package. We recommend to download and install the Haskell Platform package."
            alert.alertStyle = NSAlertStyle.warning
            alert.addButton(withTitle: "OK")
            alert.runModal()
            NSApplication.shared().terminate(self)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


    @IBAction func createNewEditorSession(_ sender: Any) {
        NotificationCenter.default.post(name:Notification.Name(rawValue:"OnNewEditorSession"), object: nil, userInfo: nil)
    }
    
    @IBAction func loadFile(_ sender: Any)
    {
        NotificationCenter.default.post(name:Notification.Name(rawValue:"OnLoadFile"), object: nil, userInfo: nil)
    }

    @IBAction func saveEditorSession(_ sender: Any) {
        NotificationCenter.default.post(name:Notification.Name(rawValue:"OnSaveEditorSession"), object: nil, userInfo: nil)
    }
    
    @IBAction func openEditorSession(_ sender: Any)
    {
        NotificationCenter.default.post(name:Notification.Name(rawValue:"OnOpenEditorSession"), object: nil, userInfo: nil)
    }
    
    @IBAction func addFile(_ sender: Any) {
        NotificationCenter.default.post(name:Notification.Name(rawValue:"OnAddFile"), object: nil, userInfo: nil)
    }
    
    @IBAction func runMain(_ sender: Any) {
                NotificationCenter.default.post(name:Notification.Name(rawValue:"OnRunMain"), object: nil, userInfo: nil)
    }
    
    @IBAction func reloadGHCi(_ sender: Any) {
                NotificationCenter.default.post(name:Notification.Name(rawValue:"OnReload"), object: nil, userInfo: nil)
    }
    
    @IBAction func clearModules(_ sender: Any) {
                NotificationCenter.default.post(name:Notification.Name(rawValue:"OnClearModules"), object: nil, userInfo: nil)
    }
    
    @IBAction func openTextEditor(_ sender: Any) {
                NotificationCenter.default.post(name:Notification.Name(rawValue:"OnOpenTextEditor"), object: nil, userInfo: nil)
    }
    
    @IBAction func openGHCDoc(_ sender: Any) {
        NSWorkspace.shared().open(URL(string: "https://downloads.haskell.org/~ghc/7.0.2/docs/html/")!)
    }
    
    @IBAction func openLibrariesDoc(_ sender: Any) {
        NSWorkspace.shared().open(URL(string: "https://downloads.haskell.org/~ghc/7.0.2/docs/html/libraries/index.html")!)
    }
    
    @IBAction func openGHCWebpage(_ sender: Any) {
        NSWorkspace.shared().open(URL(string: "https://www.haskell.org/ghc/")!)
    }
    
    @IBAction func openHaskellWebpage(_ sender: Any) {
        NSWorkspace.shared().open(URL(string: "http://haskell.org/")!)
    }
    
    @IBAction func displayGHCiCommands(_ sender: Any) {
        NotificationCenter.default.post(name:Notification.Name(rawValue:"OnDisplayCommands"), object: nil, userInfo: nil)
    }
}

