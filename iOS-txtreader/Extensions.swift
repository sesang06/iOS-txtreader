

import Foundation
import UIKit


extension UIColor {
    static func rgb(_ red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
}

class Constants {
    static let primaryColor  = UIColor.rgb(100, green: 181, blue: 246)
    static let primaryLightColor  = UIColor.rgb(155, green: 231, blue: 255)
    static let primaryDarkColor  = UIColor.rgb(34, green: 134, blue: 195)
    static let primaryTextColor = UIColor.black
    
}

class BaseCell : UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        
    }
    
    
}

class BaseTableCell : UITableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCellStyle.subtitle, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setupViews() {
        
    }
    
}

extension UIView{
    func addTopBorder(color: UIColor = UIColor.white, constant : CGFloat = 2 ,margins: CGFloat = 0) {
        let border = UIView()
        border.backgroundColor = color
        border.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(border)
        border.snp.makeConstraints { (make) in
            make.height.equalTo(constant)
        }
        border.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(-constant)
            make.trailing.equalTo(self)
            make.leading.equalTo(self)
        }
    }
    func addLeadingBorder(color: UIColor = UIColor.white, constant : CGFloat = 2 ,margins: CGFloat = 0) {
        let border = UIView()
        border.backgroundColor = color
        border.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(border)
        border.snp.makeConstraints { (make) in
            make.width.equalTo(constant)
        }
        border.snp.makeConstraints { (make) in
            make.bottom.equalTo(self)
            make.top.equalTo(self)
            make.leading.equalTo(self).offset(-constant)
        }
    }
    func addTrailingBorder(color: UIColor = UIColor.white, constant : CGFloat = 2 ,margins: CGFloat = 0) {
        let border = UIView()
        border.backgroundColor = color
        border.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(border)
        border.snp.makeConstraints { (make) in
            make.width.equalTo(constant)
        }
        border.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.bottom.equalTo(self)
            make.trailing.equalTo(self).offset(constant)
        }
    }
    func addBottomBorder(color: UIColor = UIColor.white, constant : CGFloat = 2 ,margins: CGFloat = 0) {
        let border = UIView()
        border.backgroundColor = color
        border.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(border)
        border.snp.makeConstraints { (make) in
            make.height.equalTo(constant)
        }
        border.snp.makeConstraints { (make) in
            make.bottom.equalTo(self).offset(constant)
            make.trailing.equalTo(self)
            make.leading.equalTo(self)
        }
    }
}

extension Array {
    mutating func remove(at indexes: [Int]) {
        for index in indexes.sorted(by: >) {
            remove(at: index)
        }
    }
}
//class UIAlertControllerDelegate : NSObject, UITextFieldDelegate{
//    let action : UIAlertAction
//    init(action : UIAlertAction){
//        self.action = action
//    }
//    didca
//}
extension UIViewController {
    func showAlert(title: String? = nil, message: String? = nil, completion : (()->Void)? = nil ){
        let alertController = UIAlertController(title:title , message: message, preferredStyle: .alert)
        //the confirm action taking the inputs
        let confirmAction = UIAlertAction(title: "confirm".localized, style: .default) { (_) in
            
            //getting the input values from user
            completion?()
        }
        
      
        //adding the action to dialogbox
        alertController.addAction(confirmAction)
        
        //finally presenting the dialog box
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    func showAlert(title: String? = nil, message: String? = nil, completion : ((Bool)->Void)? = nil ){
        let alertController = UIAlertController(title:title , message: message, preferredStyle: .alert)
        
        //the confirm action taking the inputs
        let confirmAction = UIAlertAction(title: "confirm".localized, style: .default) { (_) in
            
            //getting the input values from user
            completion?(true)
        }
        
        //the cancel action doing nothing
        let cancelAction = UIAlertAction(title: "cancel".localized, style: .cancel) { (_) in
            completion?(false)
        }
        
        
        //adding the action to dialogbox
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        //finally presenting the dialog box
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
   
    func showInputDialog(title : String? = nil, message : String? = nil,placeholder : String? = nil , defaultText : String? = nil, confirm : ((String?)->Void)? = nil  ) {
        //Creating UIAlertController and
        //Setting title and message for the alert dialog
        let alertController = UIAlertController(title:title , message: message, preferredStyle: .alert)
    
        //the confirm action taking the inputs
        let confirmAction = UIAlertAction(title: "confirm".localized, style: .default) { (_) in
            
            //getting the input values from user
            let input = alertController.textFields?[0].text
            confirm?(input)
        }
        
        //the cancel action doing nothing
        let cancelAction = UIAlertAction(title: "cancel".localized, style: .cancel) { (_) in
            
        }

        //adding the action to dialogbox
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        alertController.addTextField { (textField) in
            textField.placeholder = placeholder
            textField.text = defaultText
            textField.clearButtonMode = UITextFieldViewMode.whileEditing
            textField.addTarget(alertController, action: #selector(alertController.didTextChangeInputDialog), for: UIControlEvents.editingChanged)
        }
        //finally presenting the dialog box
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }

}
extension UIAlertController {
    @objc func didTextChangeInputDialog(_ sender : UITextField){
        if (sender.text?.count == 0){
            self.actions[0].isEnabled = false
            
        }else {
            self.actions[0].isEnabled = true
        }
        
    }
}
extension URL {
    var attributes: [FileAttributeKey : Any]? {
        do {
            return try FileManager.default.attributesOfItem(atPath: path)
        } catch let error as NSError {
            print("FileAttribute error: \(error)")
        }
        return nil
    }
    
    var fileSize: UInt64 {
        return attributes?[.size] as? UInt64 ?? UInt64(0)
    }
    
    var creationDate: Date? {
        return attributes?[.creationDate] as? Date
    }
    var fileName : String? {
        return self.lastPathComponent
    }
    var newFileURL : URL?{
        if !FileManager.default.fileExists(atPath: self.path) {
            return self
        }
        var index : Int = 1
        //var directory = self.pat
        
        let directoryURL = self.deletingLastPathComponent()
        var fileURL = directoryURL.appendingPathComponent("\(self.deletingPathExtension().lastPathComponent) (\(index))").appendingPathExtension(self.pathExtension)
    
        while (FileManager.default.fileExists(atPath: fileURL.path)) {
            index = index + 1
            
            fileURL = directoryURL.appendingPathComponent("\(self.deletingPathExtension().lastPathComponent) (\(index))").appendingPathExtension(self.pathExtension)
        }
        return fileURL
        
    }
}
extension UIImageView {
    func imageFrame() -> CGRect {
        let imageViewSize = self.frame.size
        guard let imageSize = self.image?.size else { return CGRect.zero}
        let imageRatio = imageSize.width / imageSize.height
        let imageViewRatio = imageViewSize.width / imageViewSize.height
        if imageRatio < imageViewRatio {
            let scaleFactor = imageViewSize.height / imageSize.height
            let width = imageSize.width * scaleFactor
            let topLeftX = (imageViewSize.width - width) * 0.5
            return CGRect(x: topLeftX, y: 0, width: width, height: imageViewSize.height)
        } else {
            let scaleFactor = imageViewSize.width / imageSize.width
            let height = imageSize.height * scaleFactor
            let topLeftY = (imageViewSize.height - height) * 0.5
            
            return CGRect(x: 0, y: topLeftY, width: imageViewSize.width, height: height)
            
        }
    }
}
extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
}
extension UIColor {
    
    static func rgb(r: CGFloat, g: CGFloat, b: CGFloat) -> UIColor {
        return UIColor(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
    
    static let backgroundColor = UIColor.rgb(r: 21, g: 22, b: 33)
    static let outlineStrokeColor = UIColor.rgb(r: 234, g: 46, b: 111)
    static let trackStrokeColor = UIColor.rgb(r: 56, g: 25, b: 49)
    static let pulsatingFillColor = UIColor.rgb(r: 86, g: 30, b: 63)
}
