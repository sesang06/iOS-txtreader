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
//        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        cv.dataSource = self
        cv.delegate = self
        
        return cv
    }()

    lazy var scrollSize : CGSize = {
       let size = CGSize(width: view.frame.width, height: view.frame.height - 40)
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
//    var count : Int = 0
//    var textContainers : [NSTextContainer] = [NSTextContainer]()
//    var textViews :[UITextView] = [UITextView]()
    var ranges : [NSRange] = [NSRange]()
    var string : NSAttributedString?
    var subStrings : [NSAttributedString] = [NSAttributedString]()
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
        self.navigationItem.title = content?.fileName
    }
    func loadText(){
        DispatchQueue.global(qos: .userInteractive).async {
            
        }
        let scrollSize = CGSize(width: view.frame.width, height: view.frame.height - 40)
        
        content?.open(completionHandler: { (success) in
            guard success else {
                return
            }
            guard  let text = self.content?.text  else {
                return
            }
           
            DispatchQueue.global(qos: .userInteractive).async {
                let attributedString = NSAttributedString(string: text , attributes: self.attributes)
                self.string = attributedString
                let textStorage = NSTextStorage(attributedString: attributedString)
                let textLayout = NSLayoutManager()
                textStorage.addLayoutManager(textLayout)
                
                //                let textContainer = NSTextContainer(size: self.view.frame.size)
                textLayout.allowsNonContiguousLayout = true
                //                textLayout.addTextContainer(textContainer)
                
                
                //                let size = CGSize(width : self.view.frame.width,  height : CGFloat.infinity)
                //                let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
                //
                //                let estimatedRect = attributedString.boundingRect(with: size, options: options, context: nil)
                
                //                self.count = Int(estimatedRect.size.height / self.scrollSize.height) + 1
                
                while(true){
                    let textContainer = NSTextContainer(size: scrollSize)
                    //                    self.textContainers.append(textContainer)
                    
                    textLayout.addTextContainer(textContainer)
                    //                    let textView = UITextView(frame: CGRect.zero, textContainer: textContainer)
                    //            let textView = UITextView(frame: CGRect(x: view.frame.size.width * CGFloat(i), y: 0, width: view.frame.size.width, height: view.frame.size.height), textContainer: textContainer)
                    //                    textView.tag = i
                    //                    textView.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0)
                    //                    textView.textContainer.lineFragmentPadding = 0
                    //                    textView.delegate = self
                    //                    //        textView.isScrollEnabled = false
                    //                    textView.isEditable = false
                    //                    textView.isPagingEnabled = true
                    //                    textView.attributedText = textString
                    //                    //            textView.isScrollEnabled = false
                    //                    //
                    //                    textViews.append(textView)
                    //                    // scrollview.addSubview(textView)
                    
                    let rangeThatFits = textLayout.glyphRange(forBoundingRect: .infinite, in: textContainer)
                    //                    print(rangeThatFits.location)
                    if (rangeThatFits.length == 0){
                        break
                    }
                    self.ranges.append(rangeThatFits)
                    
                    self.subStrings.append(attributedString.attributedSubstring(from: rangeThatFits))
                    print(Float(rangeThatFits.upperBound) / Float(attributedString.length) )
                    //                    cell.textView.attributedText = substring
                    //                    print(rangeThatFits)
                    
                }
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    self.scrollViewDidScroll(self.collectionView)
                }
            }
            
           
        })
       

        
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
        let offset = min( max(bookMarkView.frame.height / 2, translation.y + bookMarkViewOriginY ), collectionView.frame.height - bookMarkView.frame.height / 2)
        let scrollOffset = (offset - bookMarkView.frame.height / 2) / (collectionView.frame.height - bookMarkView.frame.height)
//        print(scrollOffset)
//        print((scrollview.contentSize.height - scrollview.frame.height) * scrollOffset)
        
        //        bookMarkTopConstraint?.update(offset: offset)
        collectionView.contentOffset = CGPoint(x: collectionView.contentOffset.x, y: (collectionView.contentSize.height - collectionView.frame.height) * scrollOffset)
        if gesture.state == .ended {
            self.bookMarkViewOriginY = nil
        }
    }
    deinit{
        content?.close(completionHandler: { (sucess) in
            
        })
    }

}

extension OtherTextViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        /*if*/ let count = ranges.count
            //{
        if (count != 0 && count != 1){
        let offset = collectionView.frame.height - bookMarkView.frame.height
            let currentIndex = (collectionView.contentOffset.y / collectionView.frame.height)
//            print(currentIndex)
            let indexPath = IndexPath(item: Int(currentIndex), section: 0)
            bookMarkView.index = indexPath
            bookMarkTopConstraint?.update(offset:  offset * CGFloat(currentIndex) / CGFloat(count-1) + bookMarkView.frame.height / 2)
        //        }
        }
    }
}

extension OtherTextViewController : UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.ranges.count
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
//        if let string = string {
//            let NSRange = ranges[indexPath.item]
//            let substring = string.attributedSubstring(from: NSRange)
//            cell.textView.attributedText = substring
//        }
        cell.textView.attributedText = subStrings[indexPath.item]
        cell.index = indexPath
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        print(view.frame.height)
//        print(collectionView.frame.height)
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
}


