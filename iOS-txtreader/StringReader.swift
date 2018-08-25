//
//  StringReader.swift
//  iOS-txtreader
//
//  Created by 조세상 on 2018. 8. 26..
//  Copyright © 2018년 조세상. All rights reserved.
//

import UIKit

class StringReader {
    let largeString : String
    let attributes :  [NSAttributedStringKey : Any]
    let frame : CGSize
    init?(url: URL, attributes :  [NSAttributedStringKey : Any], frame : CGSize )
    {
        guard let text = try? String(contentsOfFile: url.path, encoding: String.Encoding.utf8) else {
            return nil
        }
        self.largeString = text
        self.attributes = attributes
        self.frame = frame
        print(indice)
    }
    lazy var indice : [Int] = {
        var array = [Int]()
        var index = 0;
        array.append(index)
        while (index != largeString.count){
            index = nextIndex(startPoint: index)
            array.append(index)
            
            print("\(index) \(largeString.count)")
        }
        
        return array
        
    }()
    func pageContent(index : Int) -> String{
        let start = largeString.index(largeString.startIndex, offsetBy: indice[index])
        let end : String.Index
        if (index == largeString.count){
            end = largeString.endIndex
        }else {
            end = largeString.index(largeString.startIndex, offsetBy: indice[index+1])
        }
        let range = start..<end
        
        let temp = String(largeString[range])
        
        return temp
    }
    func isFitting(startIndex : Int, endIndex : Int) -> Bool {
        let start = largeString.index(largeString.startIndex, offsetBy: startIndex)
        let end = largeString.index(largeString.startIndex, offsetBy: endIndex)
        
        let range = start..<end
        
        let temp = String(largeString[range])
        let size = CGSize(width : frame.width,  height : CGFloat.infinity)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        let estimatedRect = NSString(string: temp).boundingRect(with: size, options: options, attributes: attributes, context: nil)
        if estimatedRect.height > frame.height {
            return true
        } else {
            return false
        }
    }
    /**
     isFitting : start ~ end ( end 미포함)에서 들어가나 안들어가나)
     원하는것 : start ~ end 가 들어가는 최후의 end
     
     인덱싱 에러 안나는것 : start ~ count
     
     **/
    
    func nextIndex(startPoint : Int) -> Int {
        var pivot = startPoint
        var nextPivot = largeString.count
        while(true){
            if (pivot >= nextPivot){
                break
            }
            let mid = (pivot + nextPivot) / 2
            let a = isFitting(startIndex: startPoint, endIndex: mid)
            let b = isFitting(startIndex: startPoint, endIndex: mid + 1)
            
            if (a && b){ //범위 늘릴 필요 있음
                nextPivot = mid - 1
            }else if (!a && !b){
                pivot = mid + 1
                
            }else {
                break
            }
        }
        print(nextPivot)
        return pivot
        for index in startPoint..<largeString.count {
            let start = largeString.index(largeString.startIndex, offsetBy: startPoint)
            let end = largeString.index(largeString.startIndex, offsetBy: index)
            
            let range = start..<end
            
            let temp = String(largeString[range])
            let size = CGSize(width : frame.width,  height : CGFloat.infinity)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            
            let estimatedRect = NSString(string: temp).boundingRect(with: size, options: options, attributes: attributes, context: nil)
            if estimatedRect.height > frame.height {
                return index
            }
            
        }
        return largeString.count
    }
    
}
