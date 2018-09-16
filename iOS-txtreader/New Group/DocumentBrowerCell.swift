//
//  DocumentTableViewCell.swift
//  iOS-txtreader
//
//  Created by 조세상 on 2018. 8. 26..
//  Copyright © 2018년 조세상. All rights reserved.
//

import UIKit

class DocumentBrowerCell: BaseTableCell {
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
//        label.text = "aaa"
        return label
    }()
    let fileInfoLabel : UILabel = {
        let label = UILabel()
//        label.text = "asdfgsazxcv"
        return label
    }()
    
    weak var content : TextDocument? {
        didSet{
            textLabel?.text = content?.fileURL.fileName
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy. MM. dd."
            let dateText : String
            if let createdDate = content?.createdDate {
                dateText = dateFormatter.string(from: createdDate)
            } else {
                dateText = ""
            }
            let fileSizeText = content?.fileSizeString ?? ""
            detailTextLabel?.text = "\(dateText) \(fileSizeText)"
            
            if content?.isFolder == true{
                imageView?.image = UIImage(named: "outline_folder_black_48pt")
            }else {
                imageView?.image = nil
            }
        }
    }
//    override func setEditing(_ editing: Bool, animated: Bool) {
//        super.setEditing(editing, animated: animated)
//
//    }
    override func setupViews() {
        
        contentView.addSubview(fileNameLabel)
        contentView.addSubview(fileInfoLabel)
        contentView.addSubview(thumbnailImageView)
        thumbnailImageView.snp.makeConstraints { (make) in
            make.top.equalTo(self.contentView).offset(10)
            make.leading.equalTo(self.contentView).offset(10)
            make.bottom.equalTo(self.contentView).offset(-10)
            make.width.equalTo(thumbnailImageView.snp.height)
        }
        fileNameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.contentView).offset(10)
            make.leading.equalTo(self.contentView).offset(10)
            make.trailing.equalTo(self.contentView).offset(-10)
            make.height.equalTo(30)
        }
        fileInfoLabel.snp.makeConstraints { (make) in
            make.top.equalTo(fileNameLabel.snp.bottom).offset(0)
            make.leading.equalTo(self.contentView).offset(10)
            make.trailing.equalTo(self.contentView).offset(-10)
            make.bottom.equalTo(self.contentView).offset(-10)
        }
    }
}
