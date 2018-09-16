//
//  BookMarkProgressView.swift
//  iOS-txtreader
//
//  Created by 조세상 on 2018. 9. 16..
//  Copyright © 2018년 조세상. All rights reserved.
// 북마크를 스와핑할 때 보여주는 안내뷰

import Foundation
import UIKit
import SnapKit

class BookMarkProgressView : UIView {
    var index : IndexPath? {
        didSet{
            if let item = index?.item{
                pageLabel.text = "\(item+1)"
            }
        }
    }
    var totalPage : Int? {
        didSet {
            guard let totalPage = totalPage else {
                return
            }
            totalPageLabel.text = "\(totalPage)"
        }
    }
    let pageLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "NanumGothic", size: 25)
        label.textAlignment = NSTextAlignment.center
        return label
    }()
    let totalPageLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "NanumGothic", size: 17)
        label.textAlignment = .center
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
        
        self.backgroundColor = .gray
        self.clipsToBounds = true
        self.layer.cornerRadius = 10
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 1
        addSubview(pageLabel)
        addSubview(totalPageLabel)
        
        pageLabel.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalTo(self)
        }
        totalPageLabel.snp.makeConstraints { (make) in
            make.bottom.leading.trailing.equalTo(self)
            make.top.equalTo(pageLabel.snp.bottom)
        }
    }
}
