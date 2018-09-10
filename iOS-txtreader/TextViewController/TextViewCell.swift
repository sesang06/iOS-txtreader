//
//  TextViewCell.swift
//  iOS-txtreader
//
//  Created by 조세상 on 2018. 8. 25..
//  Copyright © 2018년 조세상. All rights reserved.
//

import UIKit
import SnapKit
class TextViewCell: BaseCell {
    lazy var attributes :  [NSAttributedStringKey : Any] = {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 5
        let attributes : [NSAttributedStringKey : Any] = [NSAttributedStringKey.paragraphStyle : style, NSAttributedStringKey.font : UIFont(name: "NanumGothic", size: 20)!]
        return attributes
    }()
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

        tv.isScrollEnabled = false
        tv.isEditable = false
        return tv
    }()
    let pageLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "NanumGothic", size: 17)
        label.textAlignment = NSTextAlignment.center
//        label.text = "목차"
        return label
    }()
    func displayText(string : String ){
        textView.attributedText = NSAttributedString(string: string, attributes: attributes)
    }
    override func setupViews() {
        self.addSubview(textView)
        self.addSubview(pageLabel)
        textView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalTo(self)
            make.bottom.equalTo(self).offset(-40)
        }
        pageLabel.snp.makeConstraints { (make) in
            make.top.equalTo(textView.snp.bottom)
            make.trailing.leading.bottom.equalTo(self)
        }
    }
}
