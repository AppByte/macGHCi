//
//  NSUserDefaultsExtensions.swift
//  macGHCi
//
//  Created by Daniel Strebinger on 26.02.17.
//  Copyright © 2017 Daniel Strebinger. All rights reserved.
//

import Foundation
import Cocoa

extension UserDefaults {
    
    /**
     Gets the ns color
     */
    func colorForKey(key: String) -> NSColor? {
        var color: NSColor?
        if let colorData = data(forKey: key) {
            color = NSKeyedUnarchiver.unarchiveObject(with: colorData) as? NSColor
        }
        return color
    }
    
    /**
     Stores a ns color.
     */
    func setColor(color: NSColor?, forKey key: String) {
        var colorData: NSData?
        if let color = color {
            colorData = NSKeyedArchiver.archivedData(withRootObject: color) as NSData?
        }
        set(colorData, forKey: key)
    }
    
}
