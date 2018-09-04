/*
 TextFileDAO.swift
 iOS-txtreader
 
 Created by 조세상 on 2018. 9. 5..
 Copyright © 2018년 조세상. All rights reserved.
 */
import CoreData
import Foundation
import UIKit


class TextFileData{
    init(){
        return
    }
    var bookmark : Int64?
    var objectID : NSManagedObjectID?
    var fileURL : String?
    var openDate : Date?
}

class TextFileDAO{
    init(){
        
    }
    lazy var context : NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if #available(iOS 10.0, *) {
            return appDelegate.persistentContainer.viewContext
        }else {
            return appDelegate.managedObjectContext
        }
    }()
    func fetch() -> [TextFileData]{
        var textFileList = [TextFileData]()
        let fetchRequest : NSFetchRequest<TextFileMO> = TextFileMO.fetchRequest()
        
//        let reg = NSSortDescriptor(key: "a", ascending : false)
//        fetchRequest.sortDescriptors = reg
        
        do {
            let resultset = try self.context.fetch(fetchRequest)
            
            for record in resultset {
                let data = TextFileData()
                data.bookmark = record.bookmark
                data.fileURL = record.fileURL
                data.openDate = record.openDate
                data.objectID = record.objectID
                
                textFileList.append(data)
            }
        } catch let e as NSError {
            NSLog("An error has occrued : %s", e.localizedDescription)
        }
        return textFileList
    }
    
    func insert(_ data : TextFileData){
        let object = NSEntityDescription.insertNewObject(forEntityName: "TextFile", into: self.context) as! TextFileMO
        object.bookmark = data.bookmark!
        object.fileURL = data.fileURL
        object.openDate = data.openDate
        do {
            try self.context.save()
        } catch let e as NSError {
            NSLog("An error has occrued : %s", e.localizedDescription)
        }
    }
    func delete(_ objectID : NSManagedObjectID) -> Bool {
        let object = self.context.object(with: objectID)
        self.context.delete(object)
        
        do {
            try self.context.save()
            return true
        }catch let e as NSError {
            NSLog("An error has occrued : %s", e.localizedDescription)
            return false
        }
    }
}
