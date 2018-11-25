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
import RxSwift
import RxCocoa
class TextViewerSettingsViewController : SampleTextViewerViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return textFontPickerData.count
    }
    
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        return textFontPickerData[row].displayFontName
//    }
//
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let attributedString = NSAttributedString(string: textFontPickerData[row].displayFontName, attributes: [NSAttributedString.Key.font : textFontPickerData[row].font])
        return attributedString
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let textFont = textFontPickerData[row]
        UserDefaultsManager.default.textFont = textFont
        setUpTextView(true)
    }
    
    let textFontSettingLabel : UILabel = {
        let label = UILabel()
        label.text = LocalizedString.textFont
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    lazy var textFontPickerView : UIPickerView = {
        let pv = UIPickerView()
        pv.delegate = self
        pv.dataSource = self
        pv.backgroundColor = UIColor.white
        
        return pv
    }()
    let textFontPickerData = [
        TextFont(fontName: "NanumGothic", displayFontName: LocalizedString.nanumGothic),
        TextFont(fontName: "NanumMyeongjo", displayFontName: LocalizedString.nanumMyeongjo),
        TextFont(fontName: "NanumBrush", displayFontName: LocalizedString.nanumBrush),
        TextFont(fontName: "NanumPen", displayFontName: LocalizedString.nanumPen),
    ]
    lazy var textFontLabel : UILabel = {
        let label = UILabel()
        label.isUserInteractionEnabled = true
        let tg = UITapGestureRecognizer(target: self, action: #selector(textFontChange))
        label.addGestureRecognizer(tg)
        return label
    }()
    
    lazy var textFontTextField : UITextField = {
       let tf = UITextField(frame: CGRect.zero)
        tf.inputView = textFontPickerView
        let toolBar = UIToolbar()
        toolBar.isTranslucent = false
        toolBar.barStyle = .default
        toolBar.items = [
            UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(textFontDone))
            ,UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
             UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel, target: self, action: #selector(textFontCancel))
        ]
        toolBar.sizeToFit()
        tf.inputAccessoryView = toolBar
        self.view.addSubview(tf)
        return tf
    }()
    @objc func textFontDone(){
        textFontTextField.resignFirstResponder()
    }
    @objc func textFontCancel(){
        
        textFontTextField.resignFirstResponder()
    }
    let textColorSettingLabel : UILabel = {
        let label = UILabel()
        label.text = LocalizedString.textColor
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    
    let darcularCircle = UIView()
    let darcularButton : UIButton = {
        let label = UIButton(type: UIButton.ButtonType.custom)
        label.setTitle(LocalizedString.textSample, for: UIControl.State.normal)
        label.setTitleColor(UIColor.white, for: UIControl.State.normal)
        label.backgroundColor = .black
        return label
    }()
    let normalCircle = UIView()
    let normalButton : UIButton = {
        let label = UIButton(type: UIButton.ButtonType.custom)
        label.setTitle(LocalizedString.textSample, for: UIControl.State.normal)
        label.setTitleColor(UIColor.black, for: UIControl.State.normal)
        label.backgroundColor = .white
        return label
    }()
    let textSizeSettingLabel : UILabel = {
        let label = UILabel()
        label.text = LocalizedString.textSize
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()

    
    lazy var textSizeDiscreteSlider : TGPDiscreteSlider = {
        let slider = TGPDiscreteSlider()
        slider.tickCount = 3
        slider.backgroundColor = UIColor.clear
        slider.minimumValue = 0
        slider.addTarget(self, action: #selector(textSizeChange), for: UIControl.Event.valueChanged)
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
        label.text = LocalizedString.textViewMode
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigaionBar()
        setUpViews()
    }
    func setUpNavigaionBar(){
        self.navigationItem.title = LocalizedString.textViewerSetting
        let backButton = UIBarButtonItem(title: LocalizedString.close, style: UIBarButtonItem.Style.plain, target: self, action: #selector(close))
        self.navigationItem.leftBarButtonItem = backButton
       
        
    }
    
    func setUpTextView(_ animated: Bool ){
        func setUp(){
            if let attributedString = string {
                let range = NSRange.init(location: 0, length: attributedString.length)
                attributedString.setAttributes(UserDefaultsManager.default.attributes, range: range)
            }
           self.collectionView.reloadData()
            switch (UserDefaultsManager.default.viewType){
            case .darcula:
                darcularCircle.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                normalCircle.transform = CGAffineTransform.identity
            break
            case .normal:
                normalCircle.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                darcularCircle.transform = CGAffineTransform.identity
                break
                
            }
            self.textFontLabel.text = UserDefaultsManager.default.textFont.displayFontName
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
//        view.addSubview(textFontLabel)
//        textFontLabel.snp.makeConstraints { (make) in
//            make.leading.equalTo(view).offset(horizontalMargin)
//            make.trailing.equalTo(view).offset(-horizontalMargin)
//            make.top.equalTo(textFontSettingLabel.snp.bottom).offset(verticalMargin)
//        }
        view.addSubview(textFontPickerView)
        textFontPickerView.snp.makeConstraints { (make) in
            make.top.equalTo(textFontSettingLabel.snp.bottom)
            make.leading.trailing.equalTo(view)
            make.height.equalTo(100)
        }
        view.addSubview(textColorSettingLabel)
        textColorSettingLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(view).offset(horizontalMargin)
            make.trailing.equalTo(view).offset(-horizontalMargin)
            make.top.equalTo(textFontPickerView.snp.bottom)
        }
        view.addSubview(darcularCircle)
        view.addSubview(normalCircle)
        
       
        darcularCircle.snp.makeConstraints { (make) in
            make.width.height.equalTo(50)
            make.top.equalTo(textColorSettingLabel.snp.bottom).offset(verticalMargin)
            make.leading.equalTo(view).offset(horizontalMargin + 20)
            
        }
        normalCircle.snp.makeConstraints { (make) in
            make.width.height.equalTo(50)
            make.top.equalTo(textColorSettingLabel.snp.bottom).offset(verticalMargin)
            make.trailing.equalTo(view).offset(-horizontalMargin - 20)
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
            button.addTarget(self, action: #selector(textColorChange), for: UIControl.Event.touchUpInside)
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
        let selectedRow = textFontPickerData.firstIndex(where: { (textFont) -> Bool in
            return textFont == UserDefaultsManager.default.textFont
        })
        textFontPickerView.selectRow(selectedRow ?? 0, inComponent: 0, animated: false)
        textSize.asObservable()
            .throttle(0.1, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (textSize) in
                UserDefaultsManager.default.textSize = textSize
                self?.setUpTextView(true)
            })
            .disposed(by: disposeBag)
        
    }
    let disposeBag = DisposeBag()
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
//        print(sender.value)
    
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
        self.textSize.value = textSize
//        UserDefaultsManager.default.textSize = textSize
//        setUpTextView(true)
    }
    var textSize : Variable<TextSize> = Variable(UserDefaultsManager.default.textSize)
    
    
    @objc func textFontChange(){
        textFontTextField.becomeFirstResponder()
    }
    func setUpTextSize(){
        switch (UserDefaultsManager.default.textSize){
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
   
    @objc func close(_sender : Any){
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    
    
    
}
