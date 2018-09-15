//
//  TextViewerSettingsViewController.swift
//  iOS-txtreader
//
//  Created by 조세상 on 2018. 9. 14..
//  Copyright © 2018년 조세상. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
class TextViewerSettingsViewController : UIViewController {
    
    let textSettingLabel : UILabel = {
        let label = UILabel()
        label.text = "보기 모드"
        return label
    }()
    let textSettingsSwitch : UISwitch = {
       let uswitch = UISwitch()
        
        return uswitch
    }()
    override func viewDidLoad() {
        setUpNavigaionBar()
        setUpViews()
    }
    func setUpNavigaionBar(){
        self.navigationItem.title = "설정"
        let backButton = UIBarButtonItem(title: "닫기", style: UIBarButtonItemStyle.plain, target: self, action: #selector(close))
        self.navigationItem.leftBarButtonItem = backButton
       
        
    }
    func setUpViews(){
        self.view.backgroundColor = .white
        self.view.addSubview(textSettingLabel)
        textSettingLabel.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(view)
            make.top.equalTo(topLayoutGuide.snp.bottom)
            make.height.equalTo(50)
        }
        self.view.addSubview(textSettingsSwitch)
        textSettingsSwitch.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(view)
            make.top.equalTo(topLayoutGuide.snp.bottom)
            make.height.equalTo(50)
            
        }
        textSettingsSwitch.addTarget(self, action: #selector(settingChange), for: UIControlEvents.valueChanged)
    }
    @objc func settingChange(_ sender : UISwitch){
        if (sender.isOn){
            UserDefaultsManager.default.viewType = ViewType.darcula
        }else {
            UserDefaultsManager.default.viewType = ViewType.normal
        }
    }
    @objc func close(_sender : Any){
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    
}
