//
//  UserInfoManager.swift
//  iOS-txtreader
//
//  Created by 조세상 on 2018. 9. 14..
//  Copyright © 2018년 조세상. All rights reserved.
//

import Foundation
struct UserInfoKey {
    static let viewType = "VIEWTYPE"
    static let fontSize = "FONTSIZE"
}
enum ViewType : String {
    case darcula
    case normal
}
enum TextSize : Int {
    case small = 15
    case middle = 20
    case large = 25
}
class UserDefaultsManager {
    static let `default` : UserDefaultsManager =  UserDefaultsManager()
    
    var viewType : ViewType? {
        get {
            guard let viewType = UserDefaults.standard.string(forKey: UserInfoKey.viewType) else {
                return nil
            }
            return ViewType(rawValue: viewType)
        }
        set(v){
            UserDefaults.standard.set(v?.rawValue, forKey: UserInfoKey.viewType)
        }
    }
    var textSize : TextSize? {
        get {
            let viewType = UserDefaults.standard.integer(forKey: UserInfoKey.fontSize) 
            return TextSize(rawValue: viewType)
        }
        set(v){
            UserDefaults.standard.set(v?.rawValue, forKey: UserInfoKey.fontSize)
        }
    }
    
    var attributes :  [NSAttributedStringKey : Any] {
        get {
            let style = NSMutableParagraphStyle()
            style.lineSpacing = 5
            var attributes : [NSAttributedStringKey : Any] = [NSAttributedStringKey.paragraphStyle : style, NSAttributedStringKey.font : UIFont(name: "NanumGothic", size: 20)!, NSAttributedStringKey.foregroundColor : UIColor.black
            ]
            
            switch (UserDefaultsManager.default.viewType ?? .normal){
            case .darcula:
                attributes[NSAttributedStringKey.foregroundColor] = UIColor.white
            case .normal:
                attributes[NSAttributedStringKey.foregroundColor] = UIColor.black
            }
            return attributes
        }
        
    }
}
