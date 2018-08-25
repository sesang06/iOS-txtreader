//
//  TextViewCell.swift
//  iOS-txtreader
//
//  Created by 조세상 on 2018. 8. 25..
//  Copyright © 2018년 조세상. All rights reserved.
//

import UIKit

class TextViewCell: BaseCell {
    lazy var attributes :  [NSAttributedStringKey : Any] = {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 5
        let attributes : [NSAttributedStringKey : Any] = [NSAttributedStringKey.paragraphStyle : style, NSAttributedStringKey.font : UIFont(name: "NanumGothic", size: 20)!]
        return attributes
    }()
    lazy var textView : UITextView = {
        let tv = UITextView()
        tv.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0)
        tv.textContainer.lineFragmentPadding = 0
        tv.attributedText = NSAttributedString(string: "Most of the time this could be done at arm‘s length: newspapers carried lengthy reports of Parliamentary debates and set-piece platform speeches, while the messy business of street politics could mostly be delegated to constituency party workers and professional party speakers, who toured the country embroiling themselves in the unseemly controversies that most politicians sought to avoid.", attributes: attributes)
     //   tv.isScrollEnabled = false
        return tv
    }()
    func displayText(string : String ){
        textView.attributedText = NSAttributedString(string: string, attributes: attributes)
    }
    override func setupViews() {
        self.addSubview(textView)
        textView.snp.makeConstraints { (make) in
            make.top.bottom.leading.trailing.equalTo(self)
        }
    }
}
