//
//  TextViewerSettingsViewController.swift
//  iOS-txtreader
//
//  Created by 조세상 on 2018. 9. 14..
//  Copyright © 2018년 조세상. All rights reserved.
// 텍스트 뷰어를 설정함

import Foundation
import UIKit
import SnapKit
class TextViewerSettingsViewController : SampleTextViewerViewController {
    
    
    let textFontSettingLabel : UILabel = {
        let label = UILabel()
        label.text = "글씨체"
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    let textFontLabel : UILabel = {
        let label = UILabel()
        label.text = "나눔 고딕"
        return label
    }()
    
    let textColorSettingLabel : UILabel = {
        let label = UILabel()
        label.text = "색상"
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    
    let darcularCircle = UIView()
    let darcularButton : UIButton = {
        let label = UIButton(type: UIButtonType.custom)
        label.setTitle("가", for: UIControlState.normal)
        label.setTitleColor(UIColor.white, for: UIControlState.normal)
        label.backgroundColor = .black
        return label
    }()
    let normalCircle = UIView()
    let normalButton : UIButton = {
        let label = UIButton(type: UIButtonType.custom)
        label.setTitle("가", for: UIControlState.normal)
        label.setTitleColor(UIColor.black, for: UIControlState.normal)
        label.backgroundColor = .white
        return label
    }()
    let textSizeSettingLabel : UILabel = {
        let label = UILabel()
        label.text = "크기"
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()

    let textSizeSilder : UISlider = {
        let us = UISlider()
        return us
    }()
    
    
    let textSettingLabel : UILabel = {
        let label = UILabel()
        label.text = "보기 모드"
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    
    let textSettingsSwitch : UISwitch = {
       let uswitch = UISwitch()
        
        return uswitch
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigaionBar()
        setUpViews()
    }
    func setUpNavigaionBar(){
        self.navigationItem.title = "설정"
        let backButton = UIBarButtonItem(title: "닫기", style: UIBarButtonItemStyle.plain, target: self, action: #selector(close))
        self.navigationItem.leftBarButtonItem = backButton
       
        
    }
    
    func setUpTextView(_ animated: Bool ){
        func setUp(){
            if let attributedString = string {
                let range = NSRange.init(location: 0, length: attributedString.length)
                attributedString.setAttributes(UserDefaultsManager.default.attributes, range: range)
            }
           self.collectionView.reloadData()
            
        }
        if (animated){
            UIView.animate(withDuration: 0.5) {
                setUp()
                self.view.layoutIfNeeded()
            }
        }else {
            setUp()
        }
        
    }
    func setUpViews(){
        view.backgroundColor = .white
        view.addSubview(textFontSettingLabel)
        textFontSettingLabel.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(view)
            make.top.equalTo(collectionView.snp.bottom).offset(10)
        }
        view.addSubview(textFontLabel)
        textFontLabel.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(view)
            make.top.equalTo(textFontSettingLabel.snp.bottom)
        }
        view.addSubview(textColorSettingLabel)
        textColorSettingLabel.snp.makeConstraints { (make) in
            make.trailing.leading.equalTo(view)
            make.top.equalTo(textFontLabel.snp.bottom)
        }
        view.addSubview(darcularCircle)
        view.addSubview(normalCircle)
        
       
        darcularCircle.snp.makeConstraints { (make) in
            make.width.height.equalTo(100)
            make.top.equalTo(textColorSettingLabel.snp.bottom)
            make.leading.equalTo(view)
        }
        normalCircle.snp.makeConstraints { (make) in
            make.width.height.equalTo(100)
            make.top.equalTo(textColorSettingLabel.snp.bottom)
            make.trailing.equalTo(view)
        }
        darcularCircle.addSubview(darcularButton)
        normalCircle.addSubview(normalButton)
        darcularButton.snp.makeConstraints { (make) in
            make.top.bottom.leading.trailing.equalTo(darcularCircle)
        }
        normalButton.snp.makeConstraints { (make) in
            make.top.bottom.leading.trailing.equalTo(normalCircle)
        }
        
        for button in [darcularButton, normalButton] {
            button.clipsToBounds = true
            button.layer.cornerRadius = 50
            button.addTarget(self, action: #selector(textColorChange), for: UIControlEvents.touchUpInside)
        }
        for circle in [normalCircle, darcularCircle] {
            circle.layer.shadowColor = UIColor.black.cgColor
            circle.layer.shadowOpacity = 1
            circle.layer.shadowOffset = CGSize.zero
            circle.layer.shadowRadius = 10
        }
        view.addSubview(textSizeSettingLabel)
        textSizeSettingLabel.snp.makeConstraints { (make) in
            make.top.equalTo(darcularButton.snp.bottom)
            make.leading.trailing.equalTo(view)
        }
        view.addSubview(textSizeSilder)
        textSizeSilder.snp.makeConstraints { (make) in
            make.top.equalTo(textSizeSettingLabel.snp.bottom)
            make.leading.trailing.equalTo(view)
        }
        textSizeSilder.minimumValue = 0
        textSizeSilder.maximumValue = 2
        textSizeSilder.isContinuous = false
        textSizeSilder.addTarget(self, action: #selector(textSizeChange), for: UIControlEvents.valueChanged)
        
//
//        self.view.addSubview(textSettingLabel)
//        textSettingLabel.snp.makeConstraints { (make) in
//            make.leading.trailing.equalTo(view)
//            make.top.equalTo(topLayoutGuide.snp.bottom)
//            make.height.equalTo(50)
//        }
//        self.view.addSubview(textSettingsSwitch)
//        textSettingsSwitch.snp.makeConstraints { (make) in
//            make.leading.trailing.equalTo(view)
//            make.top.equalTo(topLayoutGuide.snp.bottom)
//            make.height.equalTo(50)
//
//        }
//        textSettingsSwitch.addTarget(self, action: #selector(settingChange), for: UIControlEvents.valueChanged)
        setUpTextView(false)
    }
    @objc func textColorChange(_ sender : UIButton){
        if (sender == darcularButton){
            UserDefaultsManager.default.viewType = ViewType.darcula
        }else if (sender == normalButton){
            UserDefaultsManager.default.viewType = ViewType.normal
        }
        setUpTextView(true)
    }
    @objc func textSizeChange(_ sender : UISlider){
        let textSize : TextSize
        switch ( Int(sender.value)){
            case 0:
            textSize = TextSize.small
            case 1:
            textSize = TextSize.middle
            case 2:
            textSize = TextSize.large
            default:
            textSize = TextSize.middle
        }
        UserDefaultsManager.default.textSize = textSize
        setUpTextView(true)
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
