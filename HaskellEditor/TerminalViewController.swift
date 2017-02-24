//
//  TerminalViewController.swift
//  macGHCi
//
//  Created by Daniel Strebinger on 20.02.17.
//  Copyright © 2017 Daniel Strebinger. All rights reserved.
//

import Cocoa

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
        
        return false
    }
    
    /**
     Represents the call back method of the on new data received notification.
     */
    private func ghci_OnNewDataReceivedCallBack(notification: Notification)
    {
        let userInfo = notification.userInfo
        let message  = userInfo?["message"] as? String
        
        let attributes = [NSFontAttributeName:  NSFont(name: "Consolas", size: 13)]
        self.sourceEditor.textStorage?.append(NSAttributedString(string: message!, attributes: attributes))
    }
    
    /**
     Represents the call back method of the on new error received notification.
     */
    private func ghci_OnErrorDataReceivedCallBack(notification: Notification)
    {
        let userInfo = notification.userInfo
        let message  = userInfo?["message"] as? String
        let attributes = [NSFontAttributeName:  NSFont(name: "Consolas", size: 13)]
        
       self.sourceEditor.textStorage?.setAttributedString(NSAttributedString(string: self.sourceEditor.getPreviousLineAndAppend(message: message!), attributes: attributes))   
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
        NotificationCenter.default.addObserver(forName:Notification.Name(rawValue:"OnDisplayCommands"),
                                               object:nil, queue:nil,
                                               using:ghci_OnDisplayCommandsCallBack)

    }
    
    /**
     Represents the call back method of the on new editor session notification.
     */
    private func ghci_OnNewEditorSessionCallBack(notification: Notification)
    {
        self.sourceEditor.textStorage?.mutableString.setString("")
        self.ghci.write("")
    }
    
    /**
     Represents the call back method of the on run main notification.
     */
    private func ghci_OnRunMainCallBack(notification: Notification)
    {
        self.sourceEditor.textStorage?.append(NSAttributedString(string: "\n"))
        self.ghci.write(":main")
    }
    
    /**
     Represents the call back method of the on reload notification.
     */
    private func ghci_OnReloadCallBack(notification: Notification)
    {
        self.sourceEditor.textStorage?.append(NSAttributedString(string: "\n"))
        self.ghci.write(":reload")
    }
    
    /**
     Represents the call back method of the on clear modules notification.
     */
    private func ghci_OnClearModulesCallBack(notification: Notification)
    {
        self.sourceEditor.textStorage?.append(NSAttributedString(string: "\n"))
        self.ghci.write(":load")
    }
    
    /**
     Represents the call back method of the on open text editor notification.
     */
    private func ghci_OnOpenTextEditorCallBack(notification: Notification)
    {
        self.sourceEditor.textStorage?.append(NSAttributedString(string: "\n"))
        self.ghci.write(":edit")
    }
    
    /**
     Represents the call back method of the on display commands notification.
     */
    private func ghci_OnDisplayCommandsCallBack(notification: Notification)
    {
        self.sourceEditor.textStorage?.append(NSAttributedString(string: "\n"))
        self.ghci.write(":help")
    }
    
    /**
     Represents the call back method of the on load file notification.
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
                    
                    self.sourceEditor.textStorage?.mutableString.setString(value)
                }
        })
    }
    
    /**
     Represents the call back method of the on save editor session notification.
     */
    private func ghci_OnSaveEditorSessionCallBack(notification: Notification)
    {
        let panel : NSSavePanel = NSSavePanel()
        panel.title = "Select file"
        panel.allowedFileTypes = ["hs"]
        panel.begin(
            completionHandler: {(result:Int) in
                if(result == NSFileHandlingPanelOKButton)
                {
                    FileManager.default.createFile(atPath: panel.url!.path, contents: self.sourceEditor.textStorage!.string.data(using: .utf8), attributes: nil)
                }
        })

    }
    
    /**
     Represents the call back method of the on add file notification.
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

