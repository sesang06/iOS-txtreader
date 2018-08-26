//
//  StreamReader.swift
//  iOS-txtreader
//
//  Created by 조세상 on 2018. 8. 25..
//  Copyright © 2018년 조세상. All rights reserved.
//

import UIKit
import Foundation
class StreamReader {
    let encoding: String.Encoding
    let chunkSize: Int
    let fileHandle: FileHandle
    var buffer: Data
    let delimPattern : Data
    var isAtEOF: Bool = false
    var fileSize : UInt64
    init?(url: URL, delimeter: String = "\n", encoding: String.Encoding = .utf8, chunkSize: Int = 4096)
    {
        guard let fileHandle = try? FileHandle(forReadingFrom: url) else { return nil }
        
        guard let attr = try? FileManager.default.attributesOfItem(atPath: url.path) else {
            return nil
        }
        self.fileSize = attr[FileAttributeKey.size] as! UInt64
        self.fileHandle = fileHandle
        self.chunkSize = chunkSize
        self.encoding = encoding
        buffer = Data(capacity: chunkSize)
        delimPattern = delimeter.data(using: .utf8)!
    }
    
    deinit {
        fileHandle.closeFile()
    }
    
    
    func totalPage(amount : Int ) -> Int {
        let total = Int(fileSize)
        if (total % amount == 0){
            return total / amount
        }else {
            return total / amount + 1
        }
    }
    
    func rewind() {
        fileHandle.seek(toFileOffset: 0)
        buffer.removeAll(keepingCapacity: true)
        isAtEOF = false
    }
    /**
     
    */
    
    func nextContent(offset : Int, amount : Int) -> String? {
        fileHandle.seek(toFileOffset: UInt64(offset * amount))
        let tempData = fileHandle.readData(ofLength: amount)
        if tempData.count == 0 {
            isAtEOF = true
            return nil
        }
        let line = String(data : tempData, encoding : encoding)
        return line
    }
    func nextLine() -> String? {
        if isAtEOF { return nil }
        
        repeat {
            if let range = buffer.range(of: delimPattern, options: [], in: buffer.startIndex..<buffer.endIndex) {
                let subData = buffer.subdata(in: buffer.startIndex..<range.lowerBound)
                let line = String(data: subData, encoding: encoding)
                buffer.replaceSubrange(buffer.startIndex..<range.upperBound, with: [])
                return line
            } else {
                let tempData = fileHandle.readData(ofLength: chunkSize)
                if tempData.count == 0 {
                    isAtEOF = true
                    return (buffer.count > 0) ? String(data: buffer, encoding: encoding) : nil
                }
                buffer.append(tempData)
            }
        } while true
    }
}
