//: A UIKit based Playground for presenting user interface

import UIKit
import CoreText
class MyViewController : UIViewController {
//    override func loadView() {
//        let view = UIView()
//        view.backgroundColor = .white
//
//        let label = UILabel()
//        label.frame = CGRect(x: 150, y: 200, width: 200, height: 20)
//        label.text = "Hello World!"
//        label.textColor = .black
//
//        view.addSubview(label)
//
//        self.view = view
//    }
    lazy var attributes :  [NSAttributedStringKey : Any] = {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 5
    
        switch (UserDefaultsManager.default.viewType){
        case .darcula:
            let attributes : [NSAttributedStringKey : Any] = [NSAttributedStringKey.paragraphStyle : style, NSAttributedStringKey.font : UIFont(name: "NanumGothic", size: 20)!, NSAttributedStringKey.foregroundColor : UIColor.white
            ]
            return attributes
        case .normal:
            let attributes : [NSAttributedStringKey : Any] = [NSAttributedStringKey.paragraphStyle : style, NSAttributedStringKey.font : UIFont(name: "NanumGothic", size: 20)!, NSAttributedStringKey.foregroundColor : UIColor.black
            ]
            return attributes
            
        }
        
    }()
    
    override func viewDidLoad() {
        let scrollingView = UIScrollView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height-64))
        // Make the scroll view content size big enough for four pages
        scrollingView.contentSize =
            CGSize(width:  (self.view.bounds.size.width) * 100, height: self.view.bounds.size.height-64)
        
        // Enable paging in scroll view
        scrollingView.isPagingEnabled = true;
        // Add scroll view to view
        view.addSubview(scrollingView)
        // Create string - content
       
        guard let url = Bundle.main.url(forResource:"text", withExtension: "txt") else {
            return
        }
        
        let text = try? String(contentsOfFile: url.path, encoding: String.Encoding.utf8)

        
        //        guard let text = try? String(contentsOfFile: url.path) else {
        //            return nil
        //        }
        
        
        
        let textString = NSAttributedString(string: text! , attributes: attributes)
        // Set up text storage and add string
        
        let textStorage = NSTextStorage(attributedString: textString)
        let textLayout = NSLayoutManager()
        textStorage.addLayoutManager(textLayout)
        var i = 0
        while (i<=99) {
            let textContainer = NSTextContainer(size: scrollingView.frame.size)
            textLayout.addTextContainer(textContainer)
            
            let textView = UITextView(frame: CGRect(x: scrollingView.frame.size.width * CGFloat(i), y: 0, width: scrollingView.frame.size.width, height: scrollingView.frame.size.height), textContainer: textContainer)
            textView.tag = i
            scrollingView.addSubview(textView)
            i = i+1
        }
        
    }
}
