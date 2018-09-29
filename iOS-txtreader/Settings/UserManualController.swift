//
//  UserManualController.swift
//  iOS-txtreader
//
//  Created by 조세상 on 29/09/2018.
//  Copyright © 2018 조세상. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
class UserManualController : UIViewController {
    lazy var textView : UITextView = {
        let tv = UITextView()
        tv.textContainerInset = UIEdgeInsetsMake(50, 10, 10, 10)
//        tv.textContainer.lineFragmentPadding = 0
//        tv.isUserInteractionEnabled = false
//        tv.isScrollEnabled = false
        tv.isEditable = false
        tv.backgroundColor = .clear
        tv.font = UIFont.systemFont(ofSize: 20)
        return tv
    }()
    
    func setUpText(){
        guard let fileURL = Bundle.main.url(forResource:"manual", withExtension: "txt") else {
            return
        }
        guard let text = try? String(contentsOf: fileURL, encoding: String.Encoding.utf8) else {
            return
        }
        textView.text = text
    }
    func setUpView(){
        view.backgroundColor = UIColor.white
        view.addSubview(textView)
        textView.snp.makeConstraints { (make) in
            make.topMargin.bottomMargin.leadingMargin.trailingMargin.equalTo(view)
        }
//        textView.inset
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigaionBar()
        setUpText()
        setUpView()
    }
    @objc func close(_ sender : Any){
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    func setUpNavigaionBar(){
        self.navigationItem.title = LocalizedString.help
        let backButton = UIBarButtonItem(title: LocalizedString.close, style: UIBarButtonItemStyle.plain, target: self, action: #selector(close))
        self.navigationItem.leftBarButtonItem = backButton
    }
}
