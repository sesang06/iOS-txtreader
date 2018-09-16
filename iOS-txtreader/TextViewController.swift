//
//  ViewController.swift
//  iOS-txtreader
//
//  Created by 조세상 on 2018. 8. 23..
//  Copyright © 2018년 조세상. All rights reserved.
//
import UIKit
import Foundation
import SnapKit


class TextViewController: UIViewController {
    lazy var collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    let cellId = "cellId"
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
        view.addSubview(collectionView)
        collectionView.register(TextViewerCell.self, forCellWithReuseIdentifier: cellId)
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

        
        //streamReader = StreamReader(url: url)
        print(view.frame.size)
        let size = CGSize(width: view.frame.width, height: view.frame.height - 64 - 40)
       
        DispatchQueue.global(qos: .userInteractive).async {
            let stringReader = StringReader(url: (self.content?.fileURL)!, attributes: self.attributes, frame: size)
            stringReader?.calculate(completion: { () -> (Void) in
                DispatchQueue.main.async {
                    self.stringReader = stringReader
                    self.collectionView.reloadData()
                    
                }
            })
           
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
        let offset = min( max(bookMarkView.frame.height / 2, translation.y + bookMarkViewOriginY ), collectionView.frame.height - bookMarkView.frame.height / 2)
        let scrollOffset = (offset - bookMarkView.frame.height / 2) / (collectionView.frame.height - bookMarkView.frame.height)
        print(scrollOffset)
        print((collectionView.contentSize.height - collectionView.frame.height) * scrollOffset)
        
//        bookMarkTopConstraint?.update(offset: offset)
        collectionView.contentOffset = CGPoint(x: collectionView.contentOffset.x, y: (collectionView.contentSize.height - collectionView.frame.height) * scrollOffset)
        if gesture.state == .ended {
            self.bookMarkViewOriginY = nil
        }
    }
}
extension TextViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let count = stringReader?.indice.count{
            let offset = collectionView.frame.height - bookMarkView.frame.height
            let currentIndex = (collectionView.contentOffset.y / collectionView.frame.height)
            print(currentIndex)
            let indexPath = IndexPath(item: Int(currentIndex), section: 0)
            bookMarkView.index = indexPath
            bookMarkTopConstraint?.update(offset:  offset * CGFloat(currentIndex) / CGFloat(count-1) + bookMarkView.frame.height / 2)
        }
        
    }
    
    
}
extension TextViewController : UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stringReader?.indice.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension TextViewController : UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! TextViewerCell
        cell.index = indexPath
        if let str = stringReader?.pageContent(index: indexPath.item) {
             cell.displayText(string: str)
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        print(view.frame.height)
        print(collectionView.frame.height)
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
}




