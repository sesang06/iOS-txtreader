//
//  TextDocument.swift
//  iOS-txtreader
//
//  Created by 조세상 on 2018. 8. 26..
//  Copyright © 2018년 조세상. All rights reserved.
//

import UIKit

class TextDocument: UIDocument {
    var text : String? = "asdf"
    override func contents(forType typeName: String) throws -> Any {
        if let content = text {
            let length = content.lengthOfBytes(using: String.Encoding.utf8)
            return Data(bytes: content, count: length)
        }
        // Encode your document with an instance of NSData or NSFileWrapper
        return Data()
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        // Load your document from contents
        if let userContent = contents as? Data{
            text = NSString(bytes: (contents as AnyObject).bytes, length: userContent.count, encoding: String.Encoding.utf8.rawValue) as? String
            print(text)
        }
    }
    func createdDate() -> Date {
        var theCreationDate = Date()
        do{
            let aFileAttributes = try FileManager.default.attributesOfItem(atPath: self.fileURL.path) as [FileAttributeKey:Any]
            theCreationDate = aFileAttributes[FileAttributeKey.creationDate] as! Date
    
        } catch {
            print("file not found")
        }
        return theCreationDate
    }
    func extractAndBreakFilenameInComponents(fileURL: NSURL) -> (fileName: String, fileExtension: String) {
        
        // Break the NSURL path into its components and create a new array with those components.
        let fileURLParts = fileURL.path?.components(separatedBy: "/")
        
        // Get the file name from the last position of the array above.
        let fileName = fileURLParts?.last
        
        // Break the file name into its components based on the period symbol (".").
        let filenameParts = fileName?.components(separatedBy: ".")
        
        // Return a tuple.
        return (filenameParts![0], filenameParts![1])
    }
}
