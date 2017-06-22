//
//  NSTextViewExtensions.swift
//  macGHCi
//
//  Created by Daniel Strebinger on 22.02.17.
//  Copyright © 2017 Daniel Strebinger. All rights reserved.
//

import Foundation
import Cocoa

/**
 Extens the ns text view class.
 */
extension NSTextView
{
    /**
     Gets the latest line of the editor.
     */
    public func getLatestLine() -> String
    {
        let content : String =  (self.textStorage?.string)!
        let lines : [String] = content.components(separatedBy: "\n")
        
        let line = lines[lines.count - 1]
        
        if (line != "" && (line.range(of: ">") != nil))
        {
            var lineContents = line.components(separatedBy: ">")
            return lineContents[1]
        }
        
        return line
    }
    
    /**
     Gets the latest line of the editor.
     */
    public func getPreviousLineAndAppend(message: String) -> String
    {
        let content : String =  (self.textStorage?.string)!
        var lines : [String] = content.components(separatedBy: "\n")

        lines[lines.count - 2].append(message)
        
        var newContent : String = ""
        
        for i in 0...lines.count - 1
        {
            if (lines.count - 2 >= i)
            {
                newContent.append(lines[i].appending("\n"))
                continue
            }
            
            newContent.append(lines[i])
        }
        
        self.textStorage?.mutableString.setString("")
        return newContent
    }
    
    /**
     Replaces a command at the command line.
     */
    public func replaceCommand(command: String)
    {
        let content : String =  (self.textStorage?.string)!
        let lines : [String] = content.components(separatedBy: "\n")
        
        let line = lines[lines.count - 1]
        var lineParts = line.components(separatedBy: ">")
        var newLine = lineParts[0].appending(">")
        var newContent : String = ""
        newLine.append(command)
        
        for i in 0...lines.count - 1
        {
            if (lines.count - 2 >= i)
            {
                newContent.append(lines[i].appending("\n"))
                continue
            }
            
            newContent.append(newLine)
        }
        
        self.textStorage?.mutableString.setString(newContent)
    }    
}
