//
//  TerminalManager.swift
//  macGHCi
//
//  Created by Daniel Strebinger on 21.02.17.
//  Copyright © 2017 Daniel Strebinger. All rights reserved.
//

import Foundation

/**
 Represents the interaction with the console of the system.
 
 - Author: Daniel Strebinger
 
 - Version: 1.0
 */
public class TerminalManager
{
    /**
     Represents the reference to the process of the terminal.
     */
    private let process : Process
    
    /**
     Represents the read pipe object.
     */
    private let readPipe : Pipe
    
    /**
     Represents the write pipe object.
     */
    private let writePipe : Pipe
    
    /**
     Represents the error pipe object.
     */
    private let errorPipe : Pipe

    /**
     Represents the read stream.
     */
    private var readStream : FileHandle
    
    /**
     Represents the write stream.
     */
    private var writeStream : FileHandle
    
    /**
     Represents the error stream.
     */
    private var errorStream : FileHandle
        
    /**
     Initializes a new instance of the ProcessInstance class.
     */
    public init()
    {
        self.process = Process()
        self.readPipe = Pipe()
        self.writePipe = Pipe()
        self.errorPipe = Pipe()
        self.readStream = FileHandle()
        self.writeStream = FileHandle()
        self.errorStream = FileHandle()
    }
    
    /**
     Starts a process with command line arguments.
     */
    public func start(_ command: String, args: [String]) {
        
        self.process.launchPath = command
        self.process.arguments = args
        self.process.standardOutput = self.readPipe
        self.process.standardInput = self.writePipe
        self.process.standardError = self.errorPipe
        self.errorStream = self.errorPipe.fileHandleForReading
        self.errorStream.waitForDataInBackgroundAndNotify()
        self.readStream = self.readPipe.fileHandleForReading
        self.readStream.waitForDataInBackgroundAndNotify()
        self.writeStream = self.writePipe.fileHandleForWriting
        
        NotificationCenter.default.addObserver(self, selector: #selector(receivedTerminalData(notification:)), name: NSNotification.Name.NSFileHandleDataAvailable, object: self.readStream)
        
        NotificationCenter.default.addObserver(self, selector: #selector(receivedTerminalData(notification:)), name: NSNotification.Name.NSFileHandleDataAvailable, object: self.errorStream)
        
        self.process.launch()
    }
    
    /**
     Writes to the terminal.
     */
    public func write(_ command: String)
    {
        var computeCommand : String = command
        computeCommand.append("\n")
        self.writeStream.write(computeCommand.data(using: .utf8)!)
    }
    
    /**
     Stops the terminal.
     */
    public func stop()
    {
        self.process.terminate()
        self.readStream.closeFile()
        self.writeStream.closeFile()
    }
    
    /**
     Interrupts the process for a specific time.
     */
    public func interrupt()
    {
        self.process.interrupt()
    }
    
    /**
     Resumes the process.
     */
    public func resume()
    {
        self.process.resume()
    }
    
    /**
     Represents the get data function for new data of the terminal.
     */
    @objc private func receivedTerminalData(notification: Notification)
    {
        let fh : FileHandle = notification.object as! FileHandle
        
        var data : Data = fh.availableData
        
        if (data.count > 0)
        {
            fh.waitForDataInBackgroundAndNotify()
            let str = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            
            if (fh == self.readStream)
            {
                NotificationCenter.default.post(name:Notification.Name(rawValue:"OnNewDataReceived"),
                                            object: nil, userInfo: ["message": str!])
                return
            }
            
            NotificationCenter.default.post(name:Notification.Name(rawValue:"OnErrorDataReceived"),
                                            object: nil, userInfo: ["message": str!])
        }
    }
}
