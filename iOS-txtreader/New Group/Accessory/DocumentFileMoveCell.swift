//
//  DocumentTableViewCell.swift
//  iOS-txtreader
//
//  Created by 조세상 on 2018. 8. 26..
//  Copyright © 2018년 조세상. All rights reserved.
//

import UIKit

class DocumentFileMoveCell: BaseTableCell {
    override func layoutSubviews() {
        super.layoutSubviews()
        indentationWidth = 20
        separatorInset = UIEdgeInsets(top: 0, left: indentationWidth * CGFloat(indentationLevel), bottom: 0, right: 0)
        
        self.contentView.layoutMargins.left = CGFloat(self.indentationLevel) * self.indentationWidth
        self.contentView.layoutIfNeeded()
    }
    let thumbnailImageView : UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.image = UIImage(named: "outline_folder_black_48pt")
        return iv
    }()
    let fileNameLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.textAlignment = NSTextAlignment.natural
        label.textColor = UIColor.black
        return label
    }()
   
    override func setupViews() {
        contentView.addSubview(fileNameLabel)
        contentView.addSubview(thumbnailImageView)
        thumbnailImageView.snp.makeConstraints { (make) in
            make.top.equalTo(self.contentView).offset(5)
            make.leadingMargin.equalTo(self.contentView).offset(20)
            make.bottom.equalTo(self.contentView).offset(-5)
            make.width.equalTo(thumbnailImageView.snp.height)
        }
        fileNameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.contentView).offset(5)
            make.bottom.equalTo(self.contentView).offset(-5)
            make.leading.equalTo(self.thumbnailImageView.snp.trailing).offset(5)
            make.trailing.equalTo(self.contentView).offset(-5)
        }
      
    }
}
