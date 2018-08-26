//
//  BookMarkView.swift
//  iOS-txtreader
//
//  Created by 조세상 on 2018. 8. 26..
//  Copyright © 2018년 조세상. All rights reserved.
//

import UIKit
import SnapKit
class BookMarkView: UIView {
    var index : IndexPath? {
        didSet{
            if let item = index?.item{
                pageLabel.text = "\(item+1)"
            }
        }
    }
    let pageLabel : UILabel = {
       let label = UILabel()
        label.font = UIFont(name: "NanumGothic", size: 17)
        label.textAlignment = NSTextAlignment.center
        return label
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setUpViews(){
        backgroundColor = UIColor.red
        addSubview(pageLabel)
        pageLabel.snp.makeConstraints { (make) in
            make.top.bottom.leading.trailing.equalTo(self)
        }
    }
}
