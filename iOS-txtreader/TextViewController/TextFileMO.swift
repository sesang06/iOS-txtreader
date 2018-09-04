//
//  TextFileMO.swift
//  iOS-txtreader
//
//  Created by 조세상 on 2018. 9. 5..
//  Copyright © 2018년 조세상. All rights reserved.
//

import Foundation
import CoreData
@objc(TextFileMO)
public class TextFileMO : NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TextFileMO> {
        return NSFetchRequest<TextFileMO>(entityName: "TextFile")
    }
    @NSManaged public var openDate : Date?
    @NSManaged public var fileURL : String?
    @NSManaged public var bookmark : Int64
}

