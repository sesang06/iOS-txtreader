//
//  ViewController.swift
//  iOS-txtreader
//
//  Created by 조세상 on 2018. 8. 23..
//  Copyright © 2018년 조세상. All rights reserved.
//
// 텍스트뷰를 통으로 집어넣는 것은 실패!

import UIKit
import Foundation
import SnapKit


class AnotherTextViewController: UIViewController, UITextViewDelegate {
    lazy var scrollview : UIScrollView = {
        let cv = UIScrollView(frame: .zero)
        cv.backgroundColor = UIColor.white
        cv.delegate = self
        return cv
    }()
    lazy var attributes :  [NSAttributedStringKey : Any] = {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 5
        let attributes : [NSAttributedStringKey : Any] = [NSAttributedStringKey.paragraphStyle : style, NSAttributedStringKey.font : UIFont(name: "NanumGothic", size: 20)!]
        return attributes
    }()
    weak var stringReader : StringReader?
    weak var content : TextDocument?
    let bookMarkView = BookMarkView()
    var bookMarkTopConstraint : Constraint?
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        loadText()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func setUpView(){
        view.addSubview(scrollview)
        scrollview.snp.makeConstraints { (make) in
            make.top.equalTo(topLayoutGuide.snp.bottom)
            make.bottom.equalTo(bottomLayoutGuide.snp.top)
            make.trailing.leading.equalTo(view)
        }
        view.addSubview(bookMarkView)
        bookMarkView.snp.makeConstraints { (make) in
            make.height.equalTo(40)
            make.width.equalTo(60)
            bookMarkTopConstraint = make.centerY.equalTo(topLayoutGuide.snp.bottom).offset(20).constraint
            make.trailing.equalTo(view)
        }
        let panGestureRecognizer = UIPanGestureRecognizer(target:self, action: #selector(panGestureRecognizerAction))
        bookMarkView.addGestureRecognizer(panGestureRecognizer)
    }
    func loadText(){
        
        let encoding = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(0x0422))
        let text = try? String(contentsOfFile: (content?.fileURL.path)!, encoding: encoding)
        
        //        guard let text = try? String(contentsOfFile: url.path) else {
        //            return nil
        //        }
        
    
        let textString = NSAttributedString(string: text! , attributes: attributes)
        
        let textStorage = NSTextStorage(attributedString: textString)
        let textLayout = NSLayoutManager()
        textStorage.addLayoutManager(textLayout)
        
        let textContainer = NSTextContainer(size: scrollview.frame.size)
        textLayout.allowsNonContiguousLayout = true
        
        textLayout.addTextContainer(textContainer)
        
        
        let size = CGSize(width : view.frame.width,  height : CGFloat.infinity)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        let estimatedRect = textString.boundingRect(with: size, options: options, context: nil)
        let textView = UITextView(frame: estimatedRect, textContainer:textContainer )
        textView.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0)
        textView.textContainer.lineFragmentPadding = 0
        textView.delegate = self
//        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.isPagingEnabled = true
        textView.attributedText = textString
        view.addSubview(textView)
    
        let rangeThatFits = textLayout.glyphRange(forBoundingRect: view.frame, in: textContainer)
        print(rangeThatFits)
        
        textView.snp.makeConstraints { (make) in
            make.top.bottom.leading.trailing.equalTo(view)
        }
    }
    var bookMarkViewOriginY : CGFloat?
    @objc func panGestureRecognizerAction(gesture : UIPanGestureRecognizer){
        let translation = gesture.translation(in: view)
        //   view.frame.origin.y = translation.y
        print(translation)
        if gesture.state == .began {
            bookMarkViewOriginY = bookMarkView.frame.origin.y + bookMarkView.frame.height / 2
        }
        guard let bookMarkViewOriginY = bookMarkViewOriginY  else {
            return
        }
        let offset = min( max(bookMarkView.frame.height / 2, translation.y + bookMarkViewOriginY ), scrollview.frame.height - bookMarkView.frame.height / 2)
        let scrollOffset = (offset - bookMarkView.frame.height / 2) / (scrollview.frame.height - bookMarkView.frame.height)
        print(scrollOffset)
        print((scrollview.contentSize.height - scrollview.frame.height) * scrollOffset)
        
        //        bookMarkTopConstraint?.update(offset: offset)
        scrollview.contentOffset = CGPoint(x: scrollview.contentOffset.x, y: (scrollview.contentSize.height - scrollview.frame.height) * scrollOffset)
        if gesture.state == .ended {
            self.bookMarkViewOriginY = nil
        }
    }
}
extension AnotherTextViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let count = stringReader?.indice.count{
            let offset = scrollview.frame.height - bookMarkView.frame.height
            let currentIndex = (scrollview.contentOffset.y / scrollview.frame.height)
            print(currentIndex)
            let indexPath = IndexPath(item: Int(currentIndex), section: 0)
            bookMarkView.index = indexPath
            bookMarkTopConstraint?.update(offset:  offset * CGFloat(currentIndex) / CGFloat(count-1) + bookMarkView.frame.height / 2)
        }
        
    }
//    func stringThatFitsOnScreen(originalString: String) -> String? {
//        // the visible rect area the text will fit into
//        let userWidth  = textView.bounds.size.width - textView.textContainerInset.right - textView.textContainerInset.left
//        let userHeight = textView.bounds.size.height - textView.textContainerInset.top - textView.textContainerInset.bottom
//        let rect = CGRect(x: 0, y: 0, width: userWidth, height: userHeight)
//        
//        // we need a new UITextView object to calculate the glyphRange. This is in addition to
//        // the UITextView that actually shows the text (probably a IBOutlet)
//        let tempTextView = UITextView(frame: self.textView.bounds)
//        tempTextView.font = textView.font
//        tempTextView.text = originalString
//        
//        // get the layout manager and use it to layout the text
//        let layoutManager = tempTextView.layoutManager
//        layoutManager.ensureLayout(for: tempTextView.textContainer)
//        
//        // get the range of text that fits in visible rect
//        let rangeThatFits = layoutManager.glyphRange(forBoundingRect: rect, in: tempTextView.textContainer)
//        
//        // convert from NSRange to Range
//        guard let stringRange = Range(rangeThatFits, in: originalString) else {
//            return nil
//        }
//        
//        // return the text that fits
//        let subString = originalString[stringRange]
//        return String(subString)
//    }
//
//    
}




