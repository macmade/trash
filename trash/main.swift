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
 * @file        main.swift
 * @copyright   (c) 2017, Jean-David Gadina - www.xs-labs.com
 */

import Cocoa

let current = NSURL.fileURL( withPath: "." )
let parent  = NSURL.fileURL( withPath: ".." )

do
{
    let args = try Arguments( ProcessInfo.processInfo.arguments )
    
    if( args.files.count == 0 )
    {
        print( args.usage() ?? "No files provided" )
        exit( -1 )
    }
    
    for file in args.files
    {
        var isDir: ObjCBool = false
        
        if( file.utf8.count == 0 ) 
        {
            print( "rm: empty file path" )
            exit( -1 )
        }
        
        let path = ( NSString( string: file ).expandingTildeInPath as NSString ).standardizingPath as String
        
        if( path.utf8.count == 0 )
        {
            print( "rm: empty file path" )
            exit( -1 )
        }
        
        let exists = FileManager.default.fileExists( atPath: path, isDirectory: &isDir )
        let url    = NSURL( fileURLWithPath: path, isDirectory: isDir.boolValue ) as URL
        
        if( exists == false )
        {
            if( args.force == false )
            {
                print( "rm: \( file ): No such file or directory" )
                exit( -1 )
            }
            
            continue;
        }
        
        if( url.path == current.path || url.path == parent.path )
        {
            print( "rm: \".\" and \"..\" may not be removed" )
            exit( -1 )
        }
        
        if( isDir.boolValue )
        {
            if( args.directories == false && args.recursive == false )
            {
                print( "rm: \( file ): is a directory" )
                exit( -1 )
            }
            
            do
            {
                let isEmpty = try FileManager.default.contentsOfDirectory( at: url, includingPropertiesForKeys: [], options: .skipsSubdirectoryDescendants ).count == 0
                
                if( isEmpty == false && args.recursive == false )
                {
                    print( "rm: \( file ): Directory not empty" )
                    exit( -1 )
                }
            }
            catch
            {
                print( "rm: \( file ): Cannot list directory" )
                exit( -1 )
            }
        }
        
        if( args.interactive )
        {
            print( "remove \( file )? ", terminator: "" )
            
            let input = readLine() ?? "n"
            
            if( input.trimmingCharacters( in: CharacterSet.whitespacesAndNewlines).lowercased() != "y" )
            {
                exit( -1 )
            }
        }
        
        do
        {
            try FileManager.default.trashItem( at: url, resultingItemURL: nil )
        }
        catch
        {
            print( "rm: \( file ): Cannot move to trash" )
            exit( -1 )
        }
    }
}
catch Arguments.Error.RuntimeError( let message )
{
    print( message )
    exit( -1 )
}
