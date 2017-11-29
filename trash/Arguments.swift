/*******************************************************************************
 * The MIT License (MIT)
 * 
 * Copyright (c) 2017 Jean-David Gadina - www.xs-labs.com
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 ******************************************************************************/

/*!
 * @file        Arguments.swift
 * @copyright   (c) 2017, Jean-David Gadina - www.xs-labs.com
 */

import Foundation

class Arguments
{
    public private( set ) var directories = false
    public private( set ) var force       = false
    public private( set ) var interactive = false
    public private( set ) var recursive   = false
    public private( set ) var verbose     = false
    public private( set ) var files       = [ String ]()
    
    public init( _ arguments: [ String ] ) throws
    {
        if( arguments.count < 2 )
        {
            throw Error.RuntimeError( self.usage() ?? "Unknown error" )
        }
        
        for arg in arguments.dropFirst()
        {
            if( arg.hasPrefix( "-" ) && self.files.count > 0 )
            {
                throw Error.RuntimeError( self.usage() ?? "Invalid arguments" )
            }
            else if( arg.hasPrefix( "-" ) )
            {
                let index = arg.index( arg.startIndex, offsetBy: 1 )
                let args  = arg.substring( from: index )
                
                for c in args
                {
                    if( c == "d" )
                    {
                        self.directories = true
                    }
                    else if( c == "f" )
                    {
                        self.interactive = false
                        self.force       = true
                    }
                    else if( c == "i" )
                    {
                        self.interactive = true
                        self.force       = false
                    }
                    else if( c == "R" || c == "r" )
                    {
                        self.recursive = true
                    }
                    else if( c == "v" )
                    {
                        self.verbose = true
                    }
                    else
                    {
                        throw Error.RuntimeError( "Unrecognized argument \( arg )" )
                    }
                }
            }
            else
            {
                self.files.append( arg )
            }
        }
    }
    
    public func usage() -> String?
    {
        let task   = Process()
        let stdout = Pipe()
        
        task.launchPath     = "/bin/rm"
        task.arguments      = []
        task.standardOutput = stdout
        
        task.launch()
        task.waitUntilExit()
        
        let data = stdout.fileHandleForReading.readDataToEndOfFile()
        
        return String( data: data, encoding: .utf8 )?.trimmingCharacters( in: CharacterSet.whitespacesAndNewlines )
    }
    
    public enum Error: Swift.Error
    {
        case RuntimeError( String )
    }
}
