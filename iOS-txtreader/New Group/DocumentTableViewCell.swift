//
//  DocumentTableViewCell.swift
//  iOS-txtreader
//
//  Created by 조세상 on 2018. 8. 26..
//  Copyright © 2018년 조세상. All rights reserved.
//

import UIKit

class DocumentTableViewCell: BaseTableCell {
    let bookMarkProgressView : UIView = {
        let v = UIView()
        return v
    }()
    let thumbnailImageView : UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    let fileNameLabel : UILabel = {
        let label = UILabel()
        label.text = "aaa"
        return label
    }()
    let fileInfoLabel : UILabel = {
        let label = UILabel()
        label.text = "asdfgsazxcv"
        return label
    }()
    weak var content : TextDocument? {
        didSet{
            fileNameLabel.text = content?.fileURL.fileName
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy. MM. dd."
            
            
            fileInfoLabel.text = "\(dateFormatter.string(from: (content?.createdDate)!)) \(content?.fileType) \(content?.fileSizeString)"
            if content?.isFolder == true{
                thumbnailImageView.image = UIImage(named: "outline_folder_black_48pt")
            }
        }
    }
    override func setupViews() {
        addSubview(fileNameLabel)
        addSubview(fileInfoLabel)
        addSubview(thumbnailImageView)
        thumbnailImageView.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(10)
            make.leading.equalTo(self).offset(10)
            make.bottom.equalTo(self).offset(-10)
            make.width.equalTo(thumbnailImageView.snp.height)
        }
        fileNameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(10)
            make.leading.equalTo(self).offset(10)
            make.trailing.equalTo(self).offset(-10)
            make.height.equalTo(30)
        }
        fileInfoLabel.snp.makeConstraints { (make) in
            make.top.equalTo(fileNameLabel.snp.bottom).offset(0)
            make.leading.equalTo(self).offset(10)
            make.trailing.equalTo(self).offset(-10)
            make.bottom.equalTo(self).offset(-10)
        }
    }
}
