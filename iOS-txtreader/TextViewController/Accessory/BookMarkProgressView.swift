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
        label.font = UIFont.systemFont(ofSize: 25)
        label.textAlignment = .center
        return label
    }()
    let totalPageLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
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
        self.alpha = 0.8
        self.backgroundColor = .white
        self.clipsToBounds = true
        self.layer.cornerRadius = 10
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 1
        addSubview(pageLabel)
        addSubview(totalPageLabel)
        let lineView = UIView()
        lineView.backgroundColor = UIColor.lightGray
        addSubview(lineView)
        pageLabel.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalTo(self)
        }
        lineView.snp.makeConstraints { (make) in
            make.leading.equalTo(self).offset(15)
            make.trailing.equalTo(self).offset(-15)
            make.height.equalTo(1)
            make.top.equalTo(pageLabel.snp.bottom)
        }
        totalPageLabel.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(self)
            make.top.equalTo(lineView.snp.bottom).offset(5)
            make.bottom.equalTo(self).offset(-5)
        }
    }
}
