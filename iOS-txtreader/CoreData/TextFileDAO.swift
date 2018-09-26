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
    var pages : Int64?
    var bookmark : Int64?
    var pagesString : Int64?
    var bookmarkString : Int64?
    var objectID : NSManagedObjectID?
    var fileURL : String?
    var openDate : Date?
    var encoding : UInt?
    
}

class TextFileDAO{
    static let `default` : TextFileDAO = TextFileDAO()
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
    
    func fetch(fileURL : URL? = nil) -> TextFileData?{
        if let url = fileURL {
            let format = NSPredicate(format: "fileURL == %@", url.path)
            let textFileDatas = self.fetch(predicate: format)
            if let textFileData = textFileDatas.first {
                return textFileData
            }
            
        }
        return nil
    }
    func fetchRecent() -> [TextFileData]?{
        let sortDescriptors = [NSSortDescriptor(key: "openDate", ascending: false)]
        return self.fetch(sortDescriptors: sortDescriptors)
    }
    func fetch(predicate : NSPredicate? = nil, sortDescriptors : [NSSortDescriptor]? = nil) -> [TextFileData]{
        var textFileList = [TextFileData]()
        let fetchRequest : NSFetchRequest<TextFileMO> = TextFileMO.fetchRequest()
        if let pre = predicate {
          fetchRequest.predicate = pre
        }
        fetchRequest.sortDescriptors = sortDescriptors
//        let reg = NSSortDescriptor(key: "a", ascending : false)
//        fetchRequest.sortDescriptors = reg
        
        do {
            let resultset = try self.context.fetch(fetchRequest)
            
            for record in resultset {
                let data = TextFileData()
                data.bookmark = record.bookmark
                data.bookmarkString = record.bookmarkString
                data.fileURL = record.fileURL
                data.openDate = record.openDate
                data.encoding = UInt(record.encoding)
                data.pages = record.pages
                data.objectID = record.objectID
                data.pagesString = record.pagesString
                textFileList.append(data)
            }
        } catch let e as NSError {
            NSLog("An error has occrued : %s", e.localizedDescription)
        }
        return textFileList
    }
    
    
    
    func insert(_ data : TextFileData){
        let object = NSEntityDescription.insertNewObject(forEntityName: "TextFile", into: self.context) as! TextFileMO
        object.pages = data.pages ?? 0
        object.bookmark = data.bookmark ?? 0
        object.bookmarkString = data.bookmarkString ?? 0
        object.pagesString = data.pagesString ?? 0
        object.fileURL = data.fileURL
        object.openDate = data.openDate
        
        if let encoding = data.encoding{
            object.encoding = Int64(encoding)
        }
        do {
            try self.context.save()
        } catch let e as NSError {
            NSLog("An error has occrued : %s", e.localizedDescription)
        }
    }
    
    
    /**
      옛날 데이터를 없애 버림
     **/
    func deleteOldRecords(){
        let deleteContext = self.context
        
    }
    
    func deleteAll()-> Bool{
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "TextFile")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do
        {
            try context.execute(deleteRequest)
            try context.save()
            return true
        } catch let e as NSError {
            NSLog("An error has occrued : %s", e.localizedDescription)
            return false
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
    func update(_ data : TextFileData){
        let object =  self.context.object(with: data.objectID!)
        object.setValue(data.bookmark, forKey: "bookmark")
        object.setValue(data.pages, forKey: "pages")
        object.setValue(data.encoding, forKey: "encoding")
        object.setValue(data.fileURL, forKey: "fileURL")
        object.setValue(data.pagesString, forKey: "pagesString")
        object.setValue(data.bookmarkString, forKey: "bookmarkString")
        do {
            try self.context.save()
        } catch let e as NSError {
            NSLog("An error has occrued : %s", e.localizedDescription)
        }
    }
}
