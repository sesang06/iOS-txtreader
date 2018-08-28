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


class OtherTextViewController: UIViewController, UITextViewDelegate {
    lazy var collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        cv.dataSource = self
        cv.delegate = self
        
        return cv
    }()
    lazy var scrollview : UIScrollView = {
        let cv = UIScrollView(frame: .zero)
        cv.backgroundColor = UIColor.white
        cv.delegate = self
        return cv
    }()
    lazy var scrollSize : CGSize = {
       let size = CGSize(width: view.frame.width, height: view.frame.height - 64)
        return size
    }()
    lazy var attributes :  [NSAttributedStringKey : Any] = {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 5
        let attributes : [NSAttributedStringKey : Any] = [NSAttributedStringKey.paragraphStyle : style, NSAttributedStringKey.font : UIFont(name: "NanumGothic", size: 20)!]
        return attributes
    }()
    weak var content : TextDocument?
    let cellId = "cellId"
    let bookMarkView = BookMarkView()
    var bookMarkTopConstraint : Constraint?
    var count : Int = 0
    var textContainers : [NSTextContainer] = [NSTextContainer]()
    var textViews :[UITextView] = [UITextView]()
    var ranges : [NSRange] = [NSRange]()
    var string : NSAttributedString?
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
        
        view.addSubview(collectionView)
        collectionView.register(TextViewCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.snp.makeConstraints { (make) in
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
        string = textString
        let textStorage = NSTextStorage(attributedString: textString)
        let textLayout = NSLayoutManager()
        textStorage.addLayoutManager(textLayout)
        
        let textContainer = NSTextContainer(size: view.frame.size)
        textLayout.allowsNonContiguousLayout = true
        
        textLayout.addTextContainer(textContainer)
        
        
        let size = CGSize(width : view.frame.width,  height : CGFloat.infinity)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        let estimatedRect = textString.boundingRect(with: size, options: options, context: nil)
        
        count = Int(estimatedRect.size.height / scrollSize.height) + 1
    
        for i in 0..<count {
            let textContainer = NSTextContainer(size: scrollSize)
            textContainers.append(textContainer)
            
            textLayout.addTextContainer(textContainer)
            let textView = UITextView(frame: CGRect.zero, textContainer: textContainer)
//            let textView = UITextView(frame: CGRect(x: view.frame.size.width * CGFloat(i), y: 0, width: view.frame.size.width, height: view.frame.size.height), textContainer: textContainer)
            textView.tag = i
            textView.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0)
            textView.textContainer.lineFragmentPadding = 0
            textView.delegate = self
            //        textView.isScrollEnabled = false
            textView.isEditable = false
            textView.isPagingEnabled = true
            textView.attributedText = textString
//            textView.isScrollEnabled = false
//
            textViews.append(textView)
            // scrollview.addSubview(textView)
            
            let rangeThatFits = textLayout.glyphRange(forBoundingRect: view.frame, in: textContainer)
            ranges.append(rangeThatFits)
            print(rangeThatFits)
        }
        

        
//        textView.snp.makeConstraints { (make) in
//            make.top.bottom.leading.trailing.equalTo(view)
//        }
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
extension OtherTextViewController : UIScrollViewDelegate {
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if let count = stringReader?.indice.count{
//            let offset = scrollview.frame.height - bookMarkView.frame.height
//            let currentIndex = (scrollview.contentOffset.y / scrollview.frame.height)
//            print(currentIndex)
//            let indexPath = IndexPath(item: Int(currentIndex), section: 0)
//            bookMarkView.index = indexPath
//            bookMarkTopConstraint?.update(offset:  offset * CGFloat(currentIndex) / CGFloat(count-1) + bookMarkView.frame.height / 2)
//        }
//
//    }
}

extension OtherTextViewController : UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension OtherTextViewController : UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! TextViewCell
//        let textView = UITextView(frame: CGRect.zero, textContainer: textContainers[indexPath.item])
//        textView.isScrollEnabled = false
//        cell.addSubview(textViews[indexPath.item])
//        textViews[indexPath.item].snp.makeConstraints { (make) in
//            make.top.bottom.leading.trailing.equalTo(cell)
//        }
        if let string = string {
            let NSRange = ranges[indexPath.item]
            let substring = string.attributedSubstring(from: NSRange)
            cell.textView.attributedText = substring
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        print(view.frame.height)
        print(collectionView.frame.height)
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
}


