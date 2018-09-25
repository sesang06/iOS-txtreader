//
//  ViewController.swift
//  iOS-txtreader
//
//  Created by 조세상 on 2018. 8. 23..
//  Copyright © 2018년 조세상. All rights reserved.
//
// 텍스트뷰를 통으로 집어넣는 것은 실패!
// TODO : navigation bar slide!!

import UIKit
import Foundation
import SnapKit


class SampleTextViewerViewController: UIViewController {
    
    // MARK: 콜렉션 뷰
    let cellId = "cellId"
    
    lazy var collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.gray
        cv.dataSource = self
        cv.delegate = self
//        cv.isPagingEnabled = true
//        cv.showsVerticalScrollIndicator = false
        return cv
    }()
    
    
    // MARK: 텍스트뷰의 사이즈를 미리 계산함
    lazy var textViewSize : CGSize = {
        let size = CGSize(width: view.frame.width - 60, height: view.frame.height - 40 - 30)
        return size
    }()
   // MARK: 텍스트 저장정보
    var string : NSMutableAttributedString?
    var ranges : [NSRange] = [NSRange]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
    func setUpView(){
        setUpCollectionView()
        setUpText()
        
    }
   
    
}




extension SampleTextViewerViewController {
   
    func setUpText(){
        let scrollSize = self.textViewSize
        //        shapeLayer.strokeEnd = 0
        guard let fileURL = Bundle.main.url(forResource:"lolem", withExtension: "txt") else {
            return
        }
        guard let text = try? String(contentsOf: fileURL, encoding: String.Encoding.utf8) else {
            return
        }
       
        DispatchQueue.global(qos: .userInteractive).async {
            [weak self] in
            
            let attributedString = NSMutableAttributedString(string: text , attributes: UserDefaultsManager.default.attributes)
            self?.string = attributedString
            let textStorage = NSTextStorage(attributedString: attributedString)
            let textLayout = NSLayoutManager()
            textStorage.addLayoutManager(textLayout)
            
            while(true){
                if (self == nil) {
                    break
                }
                let textContainer = NSTextContainer(size: scrollSize)
                
                textLayout.addTextContainer(textContainer)
                let rangeThatFits = textLayout.glyphRange(for: textContainer)
                if (rangeThatFits.upperBound >= attributedString.length){
                    let finalRange = NSMakeRange(rangeThatFits.location, attributedString.length - rangeThatFits.location)
                    self?.ranges.append(finalRange)
                    
                    break
                }
                self?.ranges.append(rangeThatFits)
            }
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
        
       
    }
    
}


extension SampleTextViewerViewController : UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func setUpCollectionView(){
    
        view.addSubview(collectionView)
        collectionView.backgroundColor = UIColor.gray
        collectionView.register(TextViewerCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(view)
            make.height.equalTo(200)
            make.trailing.leading.equalTo(view)
        }
    }
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
extension SampleTextViewerViewController : UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! TextViewerCell
        if let string = string {
            let NSRange = ranges[indexPath.item]
            let substring = string.attributedSubstring(from: NSRange)
            cell.textView.attributedText = substring
        }
        switch (UserDefaultsManager.default.viewType ?? .normal){
        case .darcula:
            cell.pageView.backgroundColor = UIColor.black
            cell.pageLabel.textColor = UIColor.white
            break
        case .normal:
            cell.pageView.backgroundColor = UIColor.white
            cell.pageLabel.textColor = UIColor.black
            break
        }
        cell.index = indexPath
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
}
