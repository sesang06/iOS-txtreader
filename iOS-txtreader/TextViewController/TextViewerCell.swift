//
//  TextViewCell.swift
//  iOS-txtreader
//
//  Created by 조세상 on 2018. 8. 25..
//  Copyright © 2018년 조세상. All rights reserved.
//

import UIKit
import SnapKit
class DarcularTextViewerCell : TextViewerCell{
    override func setupViews() {
        super.setupViews()
        pageView.backgroundColor = UIColor.black
        pageLabel.textColor = UIColor.white
        
    }
}
class NormalTextViewerCell : TextViewerCell {
    override func setupViews() {
        super.setupViews()
        pageView.backgroundColor = UIColor.white
        pageLabel.textColor = UIColor.black
        
    }
}
class TextViewerCell: BaseCell {
   
    var index : IndexPath? {
        didSet{
            if let item = index?.item{
                pageLabel.text = "\(item+1)"
            }
        }
    }
    lazy var textView : UITextView = {
        let tv = UITextView()
        tv.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0)
        tv.textContainer.lineFragmentPadding = 0
        tv.isUserInteractionEnabled = false
        tv.isScrollEnabled = false
        tv.isEditable = false
        tv.backgroundColor = .clear
        return tv
    }()
    let pageLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.textAlignment = NSTextAlignment.center
        return label
    }()
    
    let pageView = UIView()
    override func setupViews() {
        self.backgroundColor = .gray
        self.addSubview(pageView)
        pageView.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(5)
            make.leading.equalTo(self).offset(10)
            make.trailing.equalTo(self).offset(-10)
            make.bottom.equalTo(self).offset(-5)
        }
        
        pageView.addSubview(textView)
        pageView.addSubview(pageLabel)
        
        textView.snp.makeConstraints { (make) in
            make.top.leading.equalTo(pageView).offset(20)
            make.trailing.equalTo(pageView).offset(-20)
        }
        pageLabel.snp.makeConstraints { (make) in
            make.top.equalTo(textView.snp.bottom)
            make.height.equalTo(40)
            make.trailing.leading.bottom.equalTo(pageView)
            
        }
    }
}
