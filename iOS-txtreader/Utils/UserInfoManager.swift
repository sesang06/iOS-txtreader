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
enum FontSize : String {
    case small
    case middle
    case large
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
    var fontSize : FontSize? {
        get {
            guard let viewType = UserDefaults.standard.string(forKey: UserInfoKey.fontSize) else {
                return nil
            }
            return FontSize(rawValue: viewType)
        }
        set(v){
            UserDefaults.standard.set(v?.rawValue, forKey: UserInfoKey.fontSize)
        }
    }
    

}
