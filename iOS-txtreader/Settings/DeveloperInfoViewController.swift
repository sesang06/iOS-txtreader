//
//  DeveloperInfoViewController.swift
//  iOS-txtreader
//
//  Created by 조세상 on 2018. 9. 16..
//  Copyright © 2018년 조세상. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
class DeveloperInfoViewController : UIViewController {
    let githubURL = "https://github.com/sesang06"
    lazy var avatarImageView : UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 10
        iv.image = UIImage(named : "avatar")
        iv.isUserInteractionEnabled = true
        return iv
    }()
    lazy var emailLabel : UILabel = {
       let label = UILabel()
        label.textAlignment = NSTextAlignment.center
        label.text = "sesang06@naver.com"
        return label
    }()
    lazy var copyrightLabel : UILabel = {
        let label = UILabel()
        label.textAlignment = NSTextAlignment.center
        label.text = "Copyright 2018. Sesang Jo.\n All rights reserved."
        label.numberOfLines = 2
        return label
    }()
    override func viewDidLoad() {
        setUpNavigaionBar()
        setUpViews()
    }
    func setUpNavigaionBar(){
        self.navigationItem.title = LocalizedString.developerInfomation
        let backButton = UIBarButtonItem(title: LocalizedString.close, style: UIBarButtonItemStyle.plain, target: self, action: #selector(close))
        self.navigationItem.leftBarButtonItem = backButton
    }
    func setUpViews(){
        view.backgroundColor = .white
        view.addSubview(emailLabel)
        view.addSubview(copyrightLabel)
        view.addSubview(avatarImageView)
        emailLabel.snp.makeConstraints { (make) in
            make.trailing.leading.equalTo(view)
            make.bottom.equalTo(view.snp.centerY).offset(0)
        }
        copyrightLabel.snp.makeConstraints { (make) in
            make.trailing.leading.equalTo(view)
            make.top.equalTo(view.snp.centerY).offset(10)
        }
        avatarImageView.snp.makeConstraints { (make) in
            make.width.height.equalTo(100)
            make.bottom.equalTo(emailLabel.snp.top).offset(-20)
            make.centerX.equalTo(view)
        }
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action: #selector(github))
        avatarImageView.addGestureRecognizer(tapGestureRecognizer)
        
        
    }
    @objc func github(_ sender : Any){
        if let url = URL(string: githubURL), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    @objc func close(_ sender : Any){
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
