//
//  DocumentTableViewCell.swift
//  iOS-txtreader
//
//  Created by 조세상 on 2018. 8. 26..
//  Copyright © 2018년 조세상. All rights reserved.
//

import UIKit

class DocumentBrowerCell: BaseTableCell {
   
    let thumbnailImageView : UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    let fileNameLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = NSTextAlignment.natural
        label.textColor = UIColor.black
        return label
    }()
    let fileInfoLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textAlignment = NSTextAlignment.natural
        label.textColor = UIColor.gray
        return label
    }()
    
    let bookmarkLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = NSTextAlignment.right
        label.textColor = UIColor.gray
        return label
    }()
    weak var content : TextDocument? {
        didSet{
            fileNameLabel.text = content?.fileURL.fileName
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy. MM. dd."
            let dateText : String
            if let createdDate = content?.createdDate {
                dateText = dateFormatter.string(from: createdDate)
            } else {
                dateText = ""
            }
            let fileSizeText = content?.fileSizeString ?? ""
            fileInfoLabel.text = "\(dateText) \(fileSizeText)"
            
            if content?.isFolder == true{
                thumbnailImageView.image = UIImage(named: "outline_folder_black_48pt")
            }else {
                thumbnailImageView.image = UIImage(named: "outline_insert_drive_file_black_48pt")
            }
            if let bookmark = content?.textFileData?.bookmark, let pages = content?.textFileData?.pages  {
                bookmarkLabel.text = "\(Int(bookmark)) \(Int(pages))"
            }else {
                bookmarkLabel.text = ""
            }
        }
    }
    override func setupViews() {
        
        contentView.addSubview(fileNameLabel)
        contentView.addSubview(fileInfoLabel)
        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(bookmarkLabel)
        thumbnailImageView.snp.makeConstraints { (make) in
            make.topMargin.equalTo(self.contentView)
            make.leadingMargin.equalTo(self.contentView).offset(5)
            make.bottomMargin.equalTo(self.contentView)
            make.width.equalTo(thumbnailImageView.snp.height)
        }
        fileNameLabel.snp.makeConstraints { (make) in
            make.topMargin.equalTo(self.contentView)
            make.leading.equalTo(self.thumbnailImageView.snp.trailing).offset(5)
            make.trailingMargin.equalTo(self.contentView).offset(-5)
        }
        fileInfoLabel.snp.makeConstraints { (make) in
            make.topMargin.equalTo(fileNameLabel.snp.bottom).offset(5)
            make.leading.equalTo(self.thumbnailImageView.snp.trailing).offset(5)
            make.trailingMargin.equalTo(self.contentView).offset(-5)
            make.bottomMargin.equalTo(self.contentView)
        }
        bookmarkLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.contentView).offset(5)
            make.bottom.equalTo(self.contentView).offset(-5)
            make.trailing.equalTo(self.contentView).offset(-5)
            make.width.equalTo(100)
        }
    }
}
