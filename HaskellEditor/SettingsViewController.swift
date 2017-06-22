//
//  SettingsViewController.swift
//  macGHCi
//
//  Created by Daniel Strebinger on 26.02.17.
//  Copyright © 2017 Daniel Strebinger. All rights reserved.
//

import Cocoa

/**
 Represents the settings view controller
 */
internal class SettingsViewController: NSViewController {

    /**
     Represents the connection to the font selector.
     */
    @IBOutlet var fontSelector: NSComboBox!
    
    /**
     Represents the connection to the font color selector.
     */
    @IBOutlet var fontColorSelector: NSColorWell!
    
    /**
     Represents the connection to the font size text box.
     */
    @IBOutlet var fontSizeTextBox: NSTextField!
    
    /**
     Represents the connection to the editor background color selector.
     */
    @IBOutlet var editorBackgroundSelector: NSColorWell!
    
    /**
     Represents the user defaults.
     */
    private var userDefaults : UserDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpFontSelector()
        self.restoreSettings()
    }

    /**
     Inserts the current settings values.
     */
    private func restoreSettings()
    {
        self.fontSelector.selectItem(withObjectValue: self.userDefaults.object(forKey: "font"))
        self.fontSizeTextBox.stringValue = "\(self.userDefaults.object(forKey: "fontSize")!)"
        
        self.fontColorSelector.color = self.userDefaults.colorForKey(key: "fontColor")!
        self.editorBackgroundSelector.color = self.userDefaults.colorForKey(key: "editorBackgroundColor")!
    }
    
    /**
     Gets all the selected font colors.
     */
    private func setUpFontSelector()
    {
        let fontManager = NSFontManager.init()
        let fonts = fontManager.availableFonts
        
        for i in 0...fonts.count - 1
        {
            self.fontSelector.addItem(withObjectValue: fonts[i])
        }
    }
    
    /**
     Saves the users settings.
     */
    @IBAction func saveClicked(_ sender: Any) {
        self.userDefaults.set(self.fontSelector.itemObjectValue(at: self.fontSelector.indexOfSelectedItem), forKey: "font")
        self.userDefaults.set(Int(self.fontSizeTextBox.stringValue), forKey: "fontSize")
        self.userDefaults.setColor(color: self.fontColorSelector.color, forKey: "fontColor")
        self.userDefaults.setColor(color: self.editorBackgroundSelector.color, forKey: "editorBackgroundColor")
        NotificationCenter.default.post(name:Notification.Name(rawValue:"OnRefreshEditor"), object: nil, userInfo: nil)
    }
    
    /**
     Resets the editor to it's standard values.
     */
    @IBAction func resetValues(_ sender: Any)
    {
        self.userDefaults.set(13, forKey: "fontSize")
        self.userDefaults.set("Consolas", forKey: "font")
        self.userDefaults.setColor(color: NSColor.black, forKey: "fontColor")
        self.userDefaults.setColor(color: NSColor.white, forKey: "editorBackgroundColor")
        self.restoreSettings()
        NotificationCenter.default.post(name:Notification.Name(rawValue:"OnRefreshEditor"), object: nil, userInfo: nil)
    }
}
