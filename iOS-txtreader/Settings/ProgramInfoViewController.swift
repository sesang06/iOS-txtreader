//
//  ProgramInfoViewController.swift
//  iOS-txtreader
//
//  Created by 조세상 on 2018. 9. 16..
//  Copyright © 2018년 조세상. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class ProgramInfoViewController : UIViewController {
    lazy var appVersionLabel : UILabel = {
        let label = UILabel()
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            label.text = version
        }
        label.textAlignment = .center
        return label
    }()
    override func viewDidLoad() {
        setUpNavigaionBar()
        setUpViews()
    }
    func setUpViews(){
        view.backgroundColor = .white
        view.addSubview(appVersionLabel)
        appVersionLabel.snp.makeConstraints { (make) in
            make.trailing.leading.top.bottom.equalTo(view)
        }
        
    }
    @objc func close(_ sender : Any){
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    func setUpNavigaionBar(){
        self.navigationItem.title = "프로그램 정보"
        let backButton = UIBarButtonItem(title: LocalizedString.close, style: UIBarButtonItem.Style.plain, target: self, action: #selector(close))
        self.navigationItem.leftBarButtonItem = backButton
    }
}
