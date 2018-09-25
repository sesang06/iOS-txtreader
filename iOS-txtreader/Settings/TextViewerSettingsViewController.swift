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
import TGPControls
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
    
    lazy var textSizeDiscreteSlider : TGPDiscreteSlider = {
        let slider = TGPDiscreteSlider()
        slider.tickCount = 3
        slider.backgroundColor = UIColor.clear
        slider.minimumValue = 0
        slider.addTarget(self, action: #selector(textSizeChange), for: UIControlEvents.valueChanged)
        slider.ticksListener = textSizeLabels
        return slider
    }()
    let textSizeLabels : TGPCamelLabels = {
        let labels = TGPCamelLabels()
        labels.names = [15, 20, 25].map{"\($0)"}
        return labels
    }()
    let textSettingLabel : UILabel = {
        let label = UILabel()
        label.text = "보기 모드"
        label.font = UIFont.systemFont(ofSize: 20)
        return label
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
    let horizontalMargin = 20
    let verticalMargin = 20
    func setUpViews(){
        view.backgroundColor = .white
        view.addSubview(textFontSettingLabel)
        textFontSettingLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(view).offset(horizontalMargin)
            make.trailing.equalTo(view).offset(-horizontalMargin)
            make.top.equalTo(collectionView.snp.bottom).offset(verticalMargin)
        }
        view.addSubview(textFontLabel)
        textFontLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(view).offset(horizontalMargin)
            make.trailing.equalTo(view).offset(-horizontalMargin)
            make.top.equalTo(textFontSettingLabel.snp.bottom).offset(verticalMargin)
        }
        view.addSubview(textColorSettingLabel)
        textColorSettingLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(view).offset(horizontalMargin)
            make.trailing.equalTo(view).offset(-horizontalMargin)
            make.top.equalTo(textFontLabel.snp.bottom).offset(verticalMargin)
        }
        view.addSubview(darcularCircle)
        view.addSubview(normalCircle)
        
       
        darcularCircle.snp.makeConstraints { (make) in
            make.width.height.equalTo(50)
            make.top.equalTo(textColorSettingLabel.snp.bottom).offset(verticalMargin)
            make.leading.equalTo(view).offset(horizontalMargin)
            
        }
        normalCircle.snp.makeConstraints { (make) in
            make.width.height.equalTo(50)
            make.top.equalTo(textColorSettingLabel.snp.bottom).offset(verticalMargin)
            make.trailing.equalTo(view).offset(-horizontalMargin)
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
            button.layer.cornerRadius = 25
            button.addTarget(self, action: #selector(textColorChange), for: UIControlEvents.touchUpInside)
        }
        for circle in [normalCircle, darcularCircle] {
            circle.layer.shadowColor = UIColor.black.cgColor
            circle.layer.shadowOpacity = 0.5
            circle.layer.shadowOffset = CGSize.zero
            circle.layer.shadowRadius = 5
        }
        view.addSubview(textSizeSettingLabel)
        textSizeSettingLabel.snp.makeConstraints { (make) in
            make.top.equalTo(darcularButton.snp.bottom).offset(verticalMargin)
            make.leading.equalTo(view).offset(horizontalMargin)
            make.trailing.equalTo(view).offset(-horizontalMargin)
        }
        view.addSubview(textSizeLabels)
        view.addSubview(textSizeDiscreteSlider)
        textSizeLabels.snp.makeConstraints { (make) in
            make.leading.equalTo(view).offset(horizontalMargin)
            make.trailing.equalTo(view).offset(-horizontalMargin)
            make.top.equalTo(textSizeSettingLabel.snp.bottom).offset(verticalMargin)
            make.height.equalTo(10)
        }
        textSizeDiscreteSlider.snp.makeConstraints { (make) in
            make.leading.equalTo(view).offset(horizontalMargin)
            make.trailing.equalTo(view).offset(-horizontalMargin)
            make.height.equalTo(20)
            make.top.equalTo(textSizeLabels.snp.bottom).offset(verticalMargin)
        }
        setUpTextSize()
        
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
    @objc func textSizeChange(_ sender: TGPDiscreteSlider, event:UIEvent) {
        let textSize : TextSize
        print(sender.value)
    
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
    func setUpTextSize(){
        switch (UserDefaultsManager.default.textSize ?? .middle){
        case .small:
            textSizeDiscreteSlider.value = 0
            textSizeLabels.value = 0
        case .middle:
            textSizeDiscreteSlider.value = 1
            textSizeLabels.value = 1
        case .large :
            textSizeDiscreteSlider.value = 2
            textSizeLabels.value = 2
        }
        
       
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
