//
//  AppDelegate.swift
//  macGHCi
//
//  Created by Daniel Strebinger on 20.02.17.
//  Copyright © 2017 Daniel Strebinger. All rights reserved.
//

import Cocoa

@NSApplicationMain

/**
 Represents the main class of the app.
 */
public class AppDelegate: NSObject, NSApplicationDelegate {

    /**
     Called when the application did finish launching.
     
     - Parameter aNotification: Contains the notification.
     */
    public func applicationDidFinishLaunching(_ aNotification: Notification)
    {
        if (!FileManager.default.fileExists(atPath: "/usr/local/bin/ghci")) {
            let alert : NSAlert = NSAlert()
            alert.messageText = "Could not locate the ghci module at path /usr/local/bin/ghci"
            alert.informativeText = "In order to use this program please visit the https://www.haskell.org/downloads to download and install their latest ghc package. We recommend to download and install the Haskell Platform package."
            alert.alertStyle = NSAlert.Style.warning
            alert.addButton(withTitle: "OK")
            alert.runModal()
            NSApplication.shared.terminate(self)
        }
    }

    /**
     Called when the application will terminate.
     
     - Parameter aNotification: Contains the Notification.
     */
    public func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    /**
     Represents the call back method for the new button clicked.
     
     Parameter sender: Contains the sender object.
     */
    @IBAction func createNewEditorSession(_ sender: Any) {
        NotificationCenter.default.post(name:Notification.Name(rawValue:"OnNewEditorSession"), object: nil, userInfo: nil)
    }
    
    /**
     Represents the call back method for the load file button clicked.
     
     Parameter sender: Contains the sender object.
     */
    @IBAction func loadFile(_ sender: Any)
    {
        NotificationCenter.default.post(name:Notification.Name(rawValue:"OnLoadFile"), object: nil, userInfo: nil)
    }

    /**
     Represents the call back method for the save button clicked.
     
     Parameter sender: Contains the sender object.
     */
    @IBAction func saveEditorSession(_ sender: Any) {
        NotificationCenter.default.post(name:Notification.Name(rawValue:"OnSaveEditorSession"), object: nil, userInfo: nil)
    }
    
    /**
     Represents the call back method for the save as button clicked.
     
     Parameter sender: Contains the sender object.
     */
    @IBAction func saveAsEditorSession(_ sender: Any) {
        NotificationCenter.default.post(name:Notification.Name(rawValue:"OnSaveAsEditorSession"), object: nil, userInfo: nil)
    }
    
    /**
     Represents the call back method for the open editor button clicked.
     
     Parameter sender: Contains the sender object.
     */
    @IBAction func openEditorSession(_ sender: Any)
    {
        NotificationCenter.default.post(name:Notification.Name(rawValue:"OnOpenEditorSession"), object: nil, userInfo: nil)
    }
    
    @IBAction func addFile(_ sender: Any) {
        NotificationCenter.default.post(name:Notification.Name(rawValue:"OnAddFile"), object: nil, userInfo: nil)
    }
    
    /**
     Represents the call back method for the run main button clicked.
     
     Parameter sender: Contains the sender object.
     */
    @IBAction func runMain(_ sender: Any) {
                NotificationCenter.default.post(name:Notification.Name(rawValue:"OnRunMain"), object: nil, userInfo: nil)
    }
    
    /**
     Represents the call back method for the reload button clicked.
     
     Parameter sender: Contains the sender object.
     */
    @IBAction func reloadGHCi(_ sender: Any) {
                NotificationCenter.default.post(name:Notification.Name(rawValue:"OnReload"), object: nil, userInfo: nil)
    }
    
    /**
     Represents the call back method for the clear modules button clicked.
     
     Parameter sender: Contains the sender object.
     */
    @IBAction func clearModules(_ sender: Any) {
                NotificationCenter.default.post(name:Notification.Name(rawValue:"OnClearModules"), object: nil, userInfo: nil)
    }
    
    /**
     Represents the call back method for the open text editor button clicked.
     
     Parameter sender: Contains the sender object.
     */
    @IBAction func openTextEditor(_ sender: Any) {
                NotificationCenter.default.post(name:Notification.Name(rawValue:"OnOpenTextEditor"), object: nil, userInfo: nil)
    }
    
    /**
     Represents the call back method for the open ghc doc button clicked.
     
     Parameter sender: Contains the sender object.
     */
    @IBAction func openGHCDoc(_ sender: Any) {
        NSWorkspace.shared.open(URL(string: "https://downloads.haskell.org/~ghc/7.0.2/docs/html/")!)
    }
    
    /**
     Represents the call back method for the open libraries button clicked.
     
     Parameter sender: Contains the sender object.
     */
    @IBAction func openLibrariesDoc(_ sender: Any) {
        NSWorkspace.shared.open(URL(string: "https://downloads.haskell.org/~ghc/7.0.2/docs/html/libraries/index.html")!)
    }
    
    /**
     Represents the call back method for the open ghc website button clicked.
     
     Parameter sender: Contains the sender object.
     */
    @IBAction func openGHCWebpage(_ sender: Any) {
        NSWorkspace.shared.open(URL(string: "https://www.haskell.org/ghc/")!)
    }
    
    /**
     Represents the call back method for the open haskell website button clicked.
     
     Parameter sender: Contains the sender object.
     */
    @IBAction func openHaskellWebpage(_ sender: Any) {
        NSWorkspace.shared.open(URL(string: "http://haskell.org/")!)
    }
    
    /**
     Represents the call back method for the display commands button clicked.
     
     Parameter sender: Contains the sender object.
     */
    @IBAction func displayGHCiCommands(_ sender: Any) {
        NotificationCenter.default.post(name:Notification.Name(rawValue:"OnDisplayCommands"), object: nil, userInfo: nil)
    }
    
    /**
     Represents the call back method for the cancel execution button clicked.
     
     Parameter sender: Contains the sender object.
     */
    @IBAction func cancelExecution(_ sender: Any) {
        NotificationCenter.default.post(name:Notification.Name(rawValue:"OnCancelExecution"), object: nil, userInfo: nil)
    }
}

