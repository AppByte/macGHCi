//
//  TerminalViewController.swift
//  macGHCi
//
//  Created by Daniel Strebinger on 20.02.17.
//  Copyright © 2017 Daniel Strebinger. All rights reserved.
//

import Cocoa

/**
 
 This class represents the terminal window. It outputs and reads the haskell commands.
 
 - Version 1.1.5
 
 - Author: Daniel Strebinger
 */
internal class TerminalViewController: NSViewController, NSTextViewDelegate {
    
    /**
     Represents the reference to the source editor.
     */
    @IBOutlet var sourceEditor: NSTextView!

    /**
     Represents the terminal manager object.
     */
    private var ghci : TerminalManager = TerminalManager.init()
    
    /**
     Represents the command history object.
     */
    private var history : CommandHistory = CommandHistory.init()
    
    /**
     Represents the user defaults.
     */
    private var userDefaults : UserDefaults = UserDefaults.standard
    
    /**
     Represents the current save path of the terminal output.
     */
    private var savePath : String = ""
    
    /**
     Called when the view will appear.
     */
    internal override func viewWillAppear() {
        self.setupDefaults()
        self.sourceEditor.backgroundColor = self.userDefaults.colorForKey(key: "editorBackgroundColor")!
        self.view.window?.title = "macGHCi - Untitled.hs (not saved)"
    }
    
    /**
     Initializes a new instance of the view controller clas.
     */
    internal override func viewDidLoad() {
        super.viewDidLoad()
        self.sourceEditor.isAutomaticQuoteSubstitutionEnabled = false
        self.ghci.start("/usr/local/bin/ghci", args: [])
        self.registerNotifications()
    }
    
    /**
     Called when the view will disappear.
     */
    internal override func viewWillDisappear() {
        self.ghci.stop()
    }
    
    /**
     Represents the call back method for the command selector notificaiton.
     */
    internal func textView(_ textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool
    {
        // if enter is called
        if (commandSelector == #selector(NSResponder.insertNewline(_:))) {
            let command : String = self.sourceEditor.getLatestLine()
            self.sourceEditor.textStorage?.append(NSAttributedString(string: "\n"))
            self.history.Add(command: command)
            self.ghci.write(command)
            return true
        }
        
        if( commandSelector == #selector(NSResponder.moveUp(_:)) ) {
            self.sourceEditor.replaceCommand(command:  self.history.GetCommand(older: true))
            return true
        }
        if( commandSelector == #selector(NSResponder.moveDown(_:)) ){
            self.sourceEditor.replaceCommand(command:  self.history.GetCommand(older: false))
            return true
        }
        
        if (self.savePath != "")
        {
            self.view.window?.title = "macGHCi - " + (Foundation.URL(string: self.savePath)?.lastPathComponent)! + " (Unsaved changes)"
        }

        
        return false
    }
    
    /**
     Setups the default values.
     */
    private func setupDefaults()
    {
        if (self.userDefaults.value(forKey: "fontSize") == nil)
        {
            self.userDefaults.set(13, forKey: "fontSize")
        }
        
        if (self.userDefaults.value(forKey: "font") == nil)
        {
            self.userDefaults.set("Consolas", forKey: "font")
        }
        
        if (self.userDefaults.value(forKey: "fontColor") == nil)
        {
            self.userDefaults.setColor(color: NSColor.black, forKey: "fontColor")
        }
        
        if (self.userDefaults.value(forKey: "editorBackgroundColor") == nil)
        {
            self.userDefaults.setColor(color: NSColor.white, forKey: "editorBackgroundColor")
        }
    }
    
    /**
     Registers for the notifications to listen on.
     */
    private func registerNotifications()
    {
        // register on events. OnNewEditorSession, OnOpenEditorSession, OnLoadFile
        NotificationCenter.default.addObserver(forName:Notification.Name(rawValue:"OnNewDataReceived"),
                                               object:nil, queue:nil,
                                               using:ghci_OnNewDataReceivedCallBack)
        NotificationCenter.default.addObserver(forName:Notification.Name(rawValue:"OnErrorDataReceived"),
                                               object:nil, queue:nil,
                                               using:ghci_OnErrorDataReceivedCallBack)
        NotificationCenter.default.addObserver(forName:Notification.Name(rawValue:"OnNewEditorSession"),
                                               object:nil, queue:nil,
                                               using:ghci_OnNewEditorSessionCallBack)
        NotificationCenter.default.addObserver(forName:Notification.Name(rawValue:"OnLoadFile"),
                                               object:nil, queue:nil,
                                               using:ghci_OnLoadFileCallBack)
        NotificationCenter.default.addObserver(forName:Notification.Name(rawValue:"OnAddFile"),
                                               object:nil, queue:nil,
                                               using:ghci_OnAddFileCallBack)
        NotificationCenter.default.addObserver(forName:Notification.Name(rawValue:"OnRunMain"),
                                               object:nil, queue:nil,
                                               using:ghci_OnRunMainCallBack)
        NotificationCenter.default.addObserver(forName:Notification.Name(rawValue:"OnReload"),
                                               object:nil, queue:nil,
                                               using:ghci_OnReloadCallBack)
        NotificationCenter.default.addObserver(forName:Notification.Name(rawValue:"OnClearModules"),
                                               object:nil, queue:nil,
                                               using:ghci_OnClearModulesCallBack)
        NotificationCenter.default.addObserver(forName:Notification.Name(rawValue:"OnOpenTextEditor"),
                                               object:nil, queue:nil,
                                               using:ghci_OnOpenTextEditorCallBack)
        NotificationCenter.default.addObserver(forName:Notification.Name(rawValue:"OnOpenEditorSession"),
                                               object:nil, queue:nil,
                                               using:ghci_OnOpenEditorSessionCallBack)
        NotificationCenter.default.addObserver(forName:Notification.Name(rawValue:"OnSaveEditorSession"),
                                               object:nil, queue:nil,
                                               using:ghci_OnSaveEditorSessionCallBack)
        NotificationCenter.default.addObserver(forName:Notification.Name(rawValue:"OnSaveAsEditorSession"),
                                               object:nil, queue:nil,
                                               using:ghci_OnSaveAsEditorSessionCallBack)
        NotificationCenter.default.addObserver(forName:Notification.Name(rawValue:"OnDisplayCommands"),
                                               object:nil, queue:nil,
                                               using:ghci_OnDisplayCommandsCallBack)
        NotificationCenter.default.addObserver(forName:Notification.Name(rawValue:"OnRefreshEditor"),
                                               object:nil, queue:nil,
                                               using:onRefreshEditor)
    }
    
    /**
     Redraws the content of the source editor.
     
     - Parameter notification: Contains the notification arguments.
     */
    private func onRefreshEditor(notification: Notification)
    {
        self.sourceEditor.backgroundColor = self.userDefaults.colorForKey(key: "editorBackgroundColor")!
        let attributes = [NSFontAttributeName:  NSFont(name: self.userDefaults.object(forKey: "font") as! String, size: self.userDefaults.object(forKey: "fontSize") as! CGFloat), NSForegroundColorAttributeName: self.userDefaults.colorForKey(key: "fontColor")]
        
        self.sourceEditor.textStorage?.setAttributedString(NSAttributedString(string: (self.sourceEditor.textStorage?.string)!, attributes: attributes))
    }
    
    /**
     Represents the call back method of the on new data received notification.
     
     - Parameter notification: Contains the notification arguments.

     */
    private func ghci_OnNewDataReceivedCallBack(notification: Notification)
    {
        let userInfo = notification.userInfo
        let message  = userInfo?["message"] as? String
        
        let attributes = [NSFontAttributeName:  NSFont(name: self.userDefaults.object(forKey: "font") as! String, size: self.userDefaults.object(forKey: "fontSize") as! CGFloat), NSForegroundColorAttributeName: self.userDefaults.colorForKey(key: "fontColor")]
        self.sourceEditor.textStorage?.append(NSAttributedString(string: message!, attributes: attributes))
        self.sourceEditor.scrollToEndOfDocument(self)
    }
    
    /**
     Represents the call back method of the on new error received notification.
     
     - Parameter notification: Contains the notification arguments.

     */
    private func ghci_OnErrorDataReceivedCallBack(notification: Notification)
    {
        let userInfo = notification.userInfo
        let message  = userInfo?["message"] as? String
        let attributes = [NSFontAttributeName:  NSFont(name: self.userDefaults.object(forKey: "font") as! String, size: self.userDefaults.object(forKey: "fontSize") as! CGFloat), NSForegroundColorAttributeName: self.userDefaults.colorForKey(key: "fontColor")]
        
        self.sourceEditor.textStorage?.setAttributedString(NSAttributedString(string: self.sourceEditor.getPreviousLineAndAppend(message: message!), attributes: attributes))
        
        self.sourceEditor.scrollToEndOfDocument(self)
    }
    
    /**
     Represents the call back method of the on new editor session notification.
     
     - Parameter notification: Contains the notification arguments.

     */
    private func ghci_OnNewEditorSessionCallBack(notification: Notification)
    {
        self.savePath = ""
        self.view.window?.title = "macGHCi - Untitled.hs (not saved)"
        self.sourceEditor.textStorage?.mutableString.setString("")
        self.ghci.write("")
    }
    
    /**
     Represents the call back method of the on run main notification.
     
     - Parameter notification: Contains the notification arguments.

     */
    private func ghci_OnRunMainCallBack(notification: Notification)
    {
        self.sourceEditor.textStorage?.append(NSAttributedString(string: "\n"))
        self.ghci.write(":main")
    }
    
    /**
     Represents the call back method of the on reload notification.
     
     - Parameter notification: Contains the notification arguments.

     */
    private func ghci_OnReloadCallBack(notification: Notification)
    {
        self.sourceEditor.textStorage?.append(NSAttributedString(string: "\n"))
        self.ghci.write(":reload")
    }
    
    /**
     Represents the call back method of the on clear modules notification.
     
     - Parameter notification: Contains the notification arguments.

     */
    private func ghci_OnClearModulesCallBack(notification: Notification)
    {
        self.sourceEditor.textStorage?.append(NSAttributedString(string: "\n"))
        self.ghci.write(":load")
    }
    
    /**
     Represents the call back method of the on open text editor notification.
     
     - Parameter notification: Contains the notification arguments.

     */
    private func ghci_OnOpenTextEditorCallBack(notification: Notification)
    {
        self.sourceEditor.textStorage?.append(NSAttributedString(string: "\n"))
        self.ghci.write(":edit")
    }
    
    /**
     Represents the call back method of the on display commands notification.
     
     - Parameter notification: Contains the notification arguments.

     */
    private func ghci_OnDisplayCommandsCallBack(notification: Notification)
    {
        self.sourceEditor.textStorage?.append(NSAttributedString(string: "\n"))
        self.ghci.write(":help")
    }
    
    /**
     Represents the call back method of the on load file notification.
     
     - Parameter notification: Contains the notification arguments.

     */
    private func ghci_OnLoadFileCallBack(notification: Notification)
    {
        let panel : NSOpenPanel = NSOpenPanel()
        panel.title = "Select file"
        panel.allowedFileTypes = ["hs"]
        panel.begin(
            completionHandler: {(result:Int) in
                if(result == NSFileHandlingPanelOKButton)
                {
                    self.sourceEditor.textStorage?.append(NSAttributedString(string: "\n"))
                    self.ghci.write(":l " + panel.url!.path)
                }
        })
    }
    
    /**
     Represents the call back method of the on open editor session notification.
     
     - Parameter notification: Contains the notification arguments.

     */
    private func ghci_OnOpenEditorSessionCallBack(notification: Notification)
    {
        let panel : NSOpenPanel = NSOpenPanel()
        panel.title = "Select file"
        panel.allowedFileTypes = ["hs"]
        panel.begin(
            completionHandler: {(result:Int) in
                if(result == NSFileHandlingPanelOKButton)
                {
                    self.view.window?.title = "macGHCi - " + (panel.url?.lastPathComponent)!
                    self.sourceEditor.textStorage?.mutableString.setString("")
                    
                    var value : String = ""
                    
                    do
                    {
                        try value = NSString(contentsOf: panel.url!, encoding: String.Encoding.utf8.rawValue) as String!
                    }
                    catch _
                    {
                        value = ""
                    }
                    
                    self.sourceEditor.backgroundColor = self.userDefaults.colorForKey(key: "editorBackgroundColor")!
                    let attributes = [NSFontAttributeName:  NSFont(name: self.userDefaults.object(forKey: "font") as! String, size: self.userDefaults.object(forKey: "fontSize") as! CGFloat), NSForegroundColorAttributeName: self.userDefaults.colorForKey(key: "fontColor")]
                    
                    self.sourceEditor.textStorage?.setAttributedString(NSAttributedString(string: value, attributes: attributes))
                }
        })
    }
    
    /**
     Represents the call back method of the on save editor session notification.
     
     - Parameter notification: Contains the notification arguments.

     */
    private func ghci_OnSaveEditorSessionCallBack(notification: Notification)
    {
        if (self.savePath == "")
        {
            let panel : NSSavePanel = NSSavePanel()
            panel.title = "Save file"
            panel.allowedFileTypes = ["hs"]
            panel.begin(
                completionHandler: {(result:Int) in
                    if(result == NSFileHandlingPanelOKButton)
                    {
                        self.view.window?.title = "macGHCi - " + (panel.url?.lastPathComponent)!
                        self.savePath = panel.url!.path
                        FileManager.default.createFile(atPath: self.savePath, contents: self.sourceEditor.textStorage!.string.data(using: .utf8), attributes: nil)
                    }
            })
            
            return
        }

        FileManager.default.createFile(atPath: self.savePath, contents: self.sourceEditor.textStorage!.string.data(using: .utf8), attributes: nil)
    }
    
    /**
     Represents the call back method of the on save editor session notification.
     
     - Parameter notification: Contains the notification arguments.
     
     */
    private func ghci_OnSaveAsEditorSessionCallBack(notification: Notification)
    {
        let panel : NSSavePanel = NSSavePanel()
        panel.title = "Save file"
        panel.allowedFileTypes = ["hs"]
        panel.begin(
            completionHandler: {(result:Int) in
                if(result == NSFileHandlingPanelOKButton)
                {
                    self.view.window?.title = "macGHCi - " + (panel.url?.lastPathComponent)!
                    self.savePath = panel.url!.path
                    FileManager.default.createFile(atPath: self.savePath, contents: self.sourceEditor.textStorage!.string.data(using: .utf8), attributes: nil)
                }
        })
        
    }
    
    /**
     Represents the call back method of the on add file notification.
     
     - Parameter notification: Contains the notification arguments.

     */
    private func ghci_OnAddFileCallBack(notification: Notification)
    {
        let panel : NSOpenPanel = NSOpenPanel()
        panel.title = "Select file"
        panel.allowedFileTypes = ["hs"]
        panel.begin(
            completionHandler: {(result:Int) in
                if(result == NSFileHandlingPanelOKButton)
                {
                    self.sourceEditor.textStorage?.append(NSAttributedString(string: "\n"))
                    self.ghci.write(":add " + panel.url!.path)
                }
        })
    }
}

