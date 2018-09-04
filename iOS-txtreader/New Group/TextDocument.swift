//
//  TextDocument.swift
//  iOS-txtreader
//
//  Created by 조세상 on 2018. 8. 26..
//  Copyright © 2018년 조세상. All rights reserved.
//

import UIKit
import CoreData
class TextDocument: UIDocument {
    var text : String?
//    func fetch() -> [NSManagedObject] {
//        var context : NSManagedObjectContext!
//        
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        
//        if #available(iOS 10.0, *) {
//            context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//        } else if #available(iOS 9.0, *){
//            context = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
//        }
//    }
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
            
            let encoding = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(0x0422))
            var convertedString: NSString?
            
            let gussedEncoding = NSString.stringEncoding(for: userContent, encodingOptions: [.likelyLanguageKey:"ko"], convertedString: &convertedString, usedLossyConversion: nil)
            
//            print(convertedString)
            print(gussedEncoding)
//          text = String(data: userContent, encoding: encoding)
            text = String(convertedString!)
        }
    }
    lazy var createdDate: Date = {
        var theCreationDate = Date()
        do{
            let aFileAttributes = try FileManager.default.attributesOfItem(atPath: self.fileURL.path) as [FileAttributeKey:Any]
            theCreationDate = aFileAttributes[FileAttributeKey.creationDate] as! Date
    
        } catch {
            print("file not found")
        }
        return theCreationDate
    }()
    lazy var fileName : String? = {
        let fileURLParts = fileURL.path.components(separatedBy: "/")
        
        // Get the file name from the last position of the array above.
        let fileName = fileURLParts.last
        return fileName
    }()
    lazy var fileSize : UInt64 = {
        return fileURL.fileSize
    }()
    lazy var isFolder : Bool = {
        if fileType == "public.folder" {
            return true
        }else {
            return false
        }
    }()
    func covertToFileString(with size: UInt64) -> String {
        var convertedValue: Double = Double(size)
        var multiplyFactor = 0
        let tokens = ["bytes", "KB", "MB", "GB", "TB", "PB",  "EB",  "ZB", "YB"]
        while convertedValue > 1024 {
            convertedValue /= 1024
            multiplyFactor += 1
        }
        return String(format: "%4.2f %@", convertedValue, tokens[multiplyFactor])
    }
    lazy var fileSizeString : String = {
        return  covertToFileString(with : fileSize) 
    }()
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

