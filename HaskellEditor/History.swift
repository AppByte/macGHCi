//
//  History.swift
//  macGHCi
//
//  Created by Daniel Strebinger on 24.02.17.
//  Copyright © 2017 Daniel Strebinger. All rights reserved.
//

import Foundation


/**
 Represents the command history.
 
 - Author: Daniel Strebinger
 
 - Verison: 1.0
 */
public class CommandHistory
{
    /**
     Contains the commands.
     */
    private var history : [String]
    
    /**
     Contains the current selected command.
     */
    private var historyIndex : Int
    
    /**
     Initializes a new instance of the history class.
     */
    public init()
    {
        self.history = []
        self.historyIndex = 0
    }
    
    /**
     Adds an command to the history.
     */
    public func Add(command: String)
    {
        self.history.append(command)
        self.historyIndex = self.history.count
    }
    
    /**
     Returns a command.
     
     - Parameter older: Indicates a boolean value wheter if an older command should be given or not.
     */
    public func GetCommand(older: Bool) -> String
    {
        if (self.history.count == 0)
        {
            return ""
        }
        
        if (self.historyIndex == 0 && older)
        {
            return self.history[0]
        }
        
        if (self.historyIndex == self.history.count - 1 && !older)
        {
            return self.history[self.history.count - 1]
        }
        
        if (older)
        {
            self.historyIndex -= 1
            return self.history[self.historyIndex]
        }
        else
        {
            self.historyIndex += 1
            return self.history[self.historyIndex]
        }
    }
}
