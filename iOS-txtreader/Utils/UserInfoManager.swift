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
    static let textSize = "TEXTSIZE"
    static let textFont = "TEXTFONT"
    static let firstRun = "FIRSTRUN"
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

struct TextFont : Codable, Equatable{
    init(fontName : String, displayFontName : String) {
        self.fontName = fontName
        self.displayFontName = displayFontName
    }
    let fontName : String
    let displayFontName : String
    
}
extension TextFont {
    static let `default` = TextFont(fontName : "NanumGothic", displayFontName : LocalizedString.nanumGothic)
    var font : UIFont {
        get {
            let size = UserDefaultsManager.default.textSize
            return UIFont(name: fontName, size: CGFloat(size.rawValue))!
            
        }
    }
    static func == (lhs: TextFont, rhs: TextFont) -> Bool {
        return (lhs.fontName == rhs.fontName)
    }
}

class UserDefaultsManager {
    static let `default` : UserDefaultsManager =  UserDefaultsManager()
    
    var firstRun : Bool {
        get {
            return UserDefaults.standard.bool(forKey: UserInfoKey.firstRun)
        }
        set(v){
            UserDefaults.standard.set(v, forKey: UserInfoKey.firstRun)
        }
    }
    
    var viewType : ViewType {
        get {
            guard let viewType = UserDefaults.standard.string(forKey: UserInfoKey.viewType) else {
                return ViewType.normal
            }
            return ViewType(rawValue: viewType) ?? ViewType.normal
        }
        set(v){
            UserDefaults.standard.set(v.rawValue, forKey: UserInfoKey.viewType)
        }
    }
    var textSize : TextSize {
        get {
            let viewType = UserDefaults.standard.integer(forKey: UserInfoKey.textSize) 
            return TextSize(rawValue: viewType) ?? TextSize.middle
        }
        set(v){
            UserDefaults.standard.set(v.rawValue, forKey: UserInfoKey.textSize)
        }
    }
    
    var textFont : TextFont {
        get {
            if let savedFont = UserDefaults.standard.data(forKey: UserInfoKey.textFont){
                let decoder = JSONDecoder()
                if let decoded = try? decoder.decode(TextFont.self, from: savedFont) {
                    return decoded
                }
            }
            return TextFont.default
        }
        set(v){
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(v){
                UserDefaults.standard.set(encoded, forKey: UserInfoKey.textFont)
            }
        }
    }
    
    var attributes :  [NSAttributedString.Key : Any] {
        get {
            let style = NSMutableParagraphStyle()
            style.lineSpacing = 5
            var attributes : [NSAttributedString.Key : Any] = [NSAttributedString.Key.paragraphStyle : style, NSAttributedString.Key.foregroundColor : UIColor.black
            ]
            
            switch (UserDefaultsManager.default.viewType){
            case .darcula:
                attributes[NSAttributedString.Key.foregroundColor] = UIColor.white
            case .normal:
                attributes[NSAttributedString.Key.foregroundColor] = UIColor.black
            }
            
            
            let font = UserDefaultsManager.default.textFont.font
            attributes[NSAttributedString.Key.font] = font
            return attributes
        }
        
    }
}
