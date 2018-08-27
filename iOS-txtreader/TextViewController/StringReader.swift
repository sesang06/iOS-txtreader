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
    let attributedString : NSAttributedString
    let attributes :  [NSAttributedStringKey : Any]
    let frame : CGSize
    init?(url: URL, attributes :  [NSAttributedStringKey : Any], frame : CGSize )
    {
//        let encoding:UInt = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(
//
//            CFStringEncodings.EUC_KR.rawValue))
        let encoding = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(0x0422))
//        let text = try? String(contentsOfFile: url.path, encoding : encoding)
        guard let text = try? String(contentsOfFile: url.path, encoding : encoding) else {
            return nil
        }
        
//        guard let text = try? String(contentsOfFile: url.path) else {
//            return nil
//        }
     
        
        self.attributedString = NSAttributedString(string: text, attributes: attributes)
        self.largeString = text
        self.attributes = attributes
        self.frame = frame

//        print(text)
     
    }
    
//    init?(document : TextDocument, attributes :  [NSAttributedStringKey : Any], frame : CGSize ){
//        
//    }
    
    var indice : [Int] = [Int]()
    func calculate(completion : @escaping ()-> (Void)) {
        var array = [Int]()
        var index = 0;
        while (index != largeString.count){
            array.append(index)
            index = nextIndex(startPoint: index)
            
            
            //            print("\(index) \(largeString.count)")
        }
        indice = array
        completion()
    }
//    func precalculate(completion : @escaping ()-> (Void)) {
//        let textStorage = NSTextStorage(attributedString: attributedString)
//        let textLayout = NSLayoutManager()
//        textStorage.addLayoutManager(textLayout)
//        let textContainer = NSTextContainer(size: frame)
//        textLayout.addTextContainer(textContainer)
//    
//        attributedString.
//        while (i<=4) {
//            // Create a text container
//            NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:scrollingView.frame.size];
//            // Add text container to text layout manager
//            [textLayout addTextContainer:textContainer];
//            // Instantiate UITextView object using the text container
//            UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(scrollingView.frame.size.width*i,0,scrollingView.frame.size.width,scrollingView.frame.size.height) textContainer:textContainer];
//            // Give the container an identifier tag
//            [textView setTag:i];
//        
//        indice = array
//        completion()
//    }
    func pageContent(index : Int) -> String{
        let start = largeString.index(largeString.startIndex, offsetBy: indice[index])
        let end : String.Index
        if (index == indice.count - 1 ){
            end = largeString.endIndex
        }else {
            end = largeString.index(largeString.startIndex, offsetBy: indice[index+1])
        }
        let range = start..<end
        
        let temp = String(largeString[range])
        
        return temp
    }
    func isFitting(startIndex : Int, endIndex : Int) -> (Bool, CGFloat) {
        let start = largeString.index(largeString.startIndex, offsetBy: startIndex)
        let end = largeString.index(largeString.startIndex, offsetBy: endIndex)
        
        let range = start..<end
        
        let temp = String(largeString[range])
        let size = CGSize(width : frame.width,  height : CGFloat.infinity)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        let estimatedRect = NSString(string: temp).boundingRect(with: size, options: options, attributes: attributes, context: nil)
        
        if estimatedRect.height > frame.height {
            return (false, estimatedRect.height)
        } else {
            return (true, estimatedRect.height)
        }
    }
    /**
     isFitting : start ~ end ( end 미포함)에서 들어가나 안들어가나)
     원하는것 : start ~ end 가 들어가는 최후의 end
     
     인덱싱 에러 안나는것 : start ~ count
     
     **/
    
    func nextIndex(startPoint : Int) -> Int {
        
        var (fit, estimatedHeight ) = isFitting(startIndex: startPoint, endIndex: largeString.count)
        let realHeight = frame.height
        if fit {
            return largeString.count
        }
        
        var pivot = startPoint
        var nextPivot = largeString.count
//        var mid = Int(CGFloat(pivot) + CGFloat(nextPivot-pivot) * realHeight / estimatedHeight)
        var mid = (pivot + nextPivot) / 2
//        print(mid)
//        var mid = Int(( CGFloat(pivot) * (estimatedHeight - realHeight) +  CGFloat(nextPivot) * realHeight ) / (estimatedHeight ))
        
        while(true){
            if (pivot >= nextPivot){
                break
            }
            mid = (pivot + nextPivot) / 2
//           mid = Int(CGFloat(pivot) + CGFloat(nextPivot-pivot) * realHeight / estimatedHeight)
//            print(mid)
            let a : Bool
            
            (a ,estimatedHeight) = isFitting(startIndex: startPoint, endIndex: mid)
            let (b ,_ ) = isFitting(startIndex: startPoint, endIndex: mid + 1)
            
            if (!a && !b){ //범위 늘릴 필요 있음
                nextPivot = mid 
            }else if (a && b){
                pivot = mid + 1
                
            }else {
                break
            }
        }
        print((pivot, mid, nextPivot))
        return mid
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
