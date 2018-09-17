//
//  ViewController.swift
//  iOS-txtreader
//
//  Created by 조세상 on 2018. 8. 23..
//  Copyright © 2018년 조세상. All rights reserved.
//
// 텍스트뷰를 통으로 집어넣는 것은 실패!

import UIKit
import Foundation
import SnapKit


class TextViewerViewController: UIViewController, UITextViewDelegate {
    lazy var collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        cv.dataSource = self
        cv.delegate = self
        
        return cv
    }()
    
    lazy var bookMarkProgressView : BookMarkProgressView = {
        let bmp = BookMarkProgressView()
        bmp.isHidden = true
        return bmp
    }()
    
    lazy var scrollSize : CGSize = {
       let size = CGSize(width: view.frame.width, height: view.frame.height - 40 - 64)
        return size
    }()
    lazy var textLoadingProgressView : TextLoadingProgressView = {
       let tlpv = TextLoadingProgressView(frame: view.frame)
        return tlpv
    }()
    lazy var attributes :  [NSAttributedStringKey : Any] = {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 5
        
        switch (UserDefaultsManager.default.viewType){
        case .darcula?:
            let attributes : [NSAttributedStringKey : Any] = [NSAttributedStringKey.paragraphStyle : style, NSAttributedStringKey.font : UIFont(name: "NanumGothic", size: 20)!, NSAttributedStringKey.foregroundColor : UIColor.white
            ]
            return attributes
        case .normal?:
            let attributes : [NSAttributedStringKey : Any] = [NSAttributedStringKey.paragraphStyle : style, NSAttributedStringKey.font : UIFont(name: "NanumGothic", size: 20)!, NSAttributedStringKey.foregroundColor : UIColor.black
            ]
            return attributes
        default:
            break
        }
        let attributes : [NSAttributedStringKey : Any] = [NSAttributedStringKey.paragraphStyle : style, NSAttributedStringKey.font : UIFont(name: "NanumGothic", size: 20)!, NSAttributedStringKey.foregroundColor : UIColor.black
        ]
        return attributes
        
    }()
    weak var content : TextDocument? {
        didSet{
            fetchTextFileData()
            setUpText()
        }
    }
    
    
    let cellId = "cellId"
    let bookMarkView = BookMarkView()
    var bookMarkTopConstraint : Constraint?
    let bookMarkMargin : CGFloat = 64
    
    var ranges : [NSRange] = [NSRange]()
    var searchRange : NSRange?
    var string : NSMutableAttributedString?
    
    var textFileData : TextFileData?
    
    let documentInteractionController = UIDocumentInteractionController()
    
    var bookMarkViewOriginY : CGFloat?
    
    lazy var toolbar : UIToolbar = {
       let toolbar = UIToolbar()
        return toolbar
    }()
    lazy var defaultToolBarItems : [UIBarButtonItem] = {
        let searchBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.search, target: self, action: #selector(searchText))
        let exportBarButton = UIBarButtonItem(title: "내보내기", style: .plain, target: self, action: #selector(exportText))
        let readModeBarButton = UIBarButtonItem(title: "보기 모드", style: UIBarButtonItemStyle.plain, target: self, action: #selector(viewerMode))
        return [
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil),
            searchBarButton,
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil),
            exportBarButton,
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil),
            readModeBarButton,
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        ]
    }()
    lazy var searchToolBarItems : [UIBarButtonItem] = {
        let searchPreviousBarButton = UIBarButtonItem(title: "이전 탐색", style: UIBarButtonItemStyle.plain, target: self, action: #selector(searchPrevious))
        let searchNextBarButton = UIBarButtonItem(title: "다음 탐색", style: UIBarButtonItemStyle.plain, target: self, action: #selector(searchNext))
        return [
             UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil),
             searchPreviousBarButton,
              UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil),
              searchNextBarButton,
               UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        ]
    }()
    
    lazy var searchBar : UISearchBar = {
       let searchBar = UISearchBar()
        searchBar.isHidden = true
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        return searchBar
    }()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpView()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpSearchBar()
        setUpToolbar()
        
    }
   
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setToolbarHidden(true, animated: false)
        updateTextFileData()
    }
    func setUpView(){
        self.view.backgroundColor = .white
        setUpCollectionView()
        setUpBookMark()
        setUpNavigationBar()
        setUpTapNavigationBarSettings()
    }
    deinit{
        content?.close(completionHandler: { (sucess) in
        })
    }

}

extension TextViewerViewController {
    @objc func viewerMode(){
        
    }
    @objc func exportText(){
        DispatchQueue.main.async {
            self.documentInteractionController.url = self.content?.fileURL
            self.documentInteractionController.delegate = self
            self.documentInteractionController.presentOptionsMenu(from: self.view.frame, in: self.view, animated: true)
        }
    }
    
    func setUpToolbar(){
        self.navigationController?.setToolbarHidden(false, animated: false)
        
        self.toolbarItems = defaultToolBarItems
//        self.navigationController?.toolbar.items = items
        //        self.navigationController?.setToolbarItems(defaultToolBarItems, animated: false)
//        self.navigationController?.toolbar.items = defaultToolBarItems
//        view.addSubview(toolbar)
//        toolbar.snp.makeConstraints { (make) in
//            make.bottom.trailing.leading.equalTo(view)
//        }
//
//        toolbar.items = defaultToolBarItems
        
    }
    
}

extension TextViewerViewController {
    func setUpNavigationBar(){
        self.navigationItem.title = content?.fileName
    }
    override var prefersStatusBarHidden: Bool {
        return navigationController?.isNavigationBarHidden == true
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return UIStatusBarAnimation.slide
    }
    
    @objc func toggle() {
        navigationController?.setNavigationBarHidden(navigationController?.isNavigationBarHidden == false, animated: true)
    }
    
}
extension TextViewerViewController {
    func fetchTextFileData(){
        let data = TextFileDAO.default.fetch(fileURL: content?.fileURL)
        if data == nil {
            let data = TextFileData()
            data.bookmark = 0
            data.fileURL = content?.fileURL.path
            data.openDate = Date()
            TextFileDAO.default.insert(data)
            self.textFileData = TextFileDAO.default.fetch(fileURL: content?.fileURL)
        }else {
            self.textFileData = data
            content?.encoding = self.textFileData?.encoding
        }
    }
    func updateTextFileData(){
        let currentIndex = (collectionView.contentOffset.y / collectionView.frame.height)
        //            print(currentIndex)
        let indexPath = IndexPath(item: Int(currentIndex), section: 0)
        print(content?.encoding)
        self.textFileData?.encoding = content?.encoding
        self.textFileData?.bookmark = Int64(indexPath.item)
        if let data = self.textFileData {
            
            TextFileDAO.default.update(data)
        }
    }
    func setUpText(){
        let scrollSize = self.scrollSize
        //        shapeLayer.strokeEnd = 0
        
        if (content == nil){
            print("error")
        }
        content?.open(completionHandler: { (success) in
            guard success else {
                return
            }
            guard  let text = self.content?.text  else {
                return
            }
            
            DispatchQueue.global(qos: .userInteractive).async {
                let attributedString = NSMutableAttributedString(string: text , attributes: self.attributes)
                self.string = attributedString
                let textStorage = NSTextStorage(attributedString: attributedString)
                let textLayout = NSLayoutManager()
                textStorage.addLayoutManager(textLayout)
                
                //                let textContainer = NSTextContainer(size: self.view.frame.size)
                textLayout.allowsNonContiguousLayout = true
                
                while(true){
                    let textContainer = NSTextContainer(size: scrollSize)
                    
                    textLayout.addTextContainer(textContainer)
                 
                    
                    let rangeThatFits = textLayout.glyphRange(for: textContainer)
                    print(rangeThatFits.upperBound)
                    print(self.string?.length)
                    //                    print(rangeThatFits.location)
                    if (rangeThatFits.upperBound >= attributedString.length){
                        let finalRange = NSMakeRange(rangeThatFits.location, attributedString.length - rangeThatFits.location)
                        self.ranges.append(finalRange)
                        
                        break
                    }
                    self.ranges.append(rangeThatFits)
                    
                    let percentage = CGFloat(rangeThatFits.upperBound) / CGFloat(attributedString.length)
                    self.textLoadingProgressView.percentage = percentage
                  }
                DispatchQueue.main.async {
                    self.textLoadingProgressView.isHidden = true
                    self.collectionView.reloadData()
                    self.bookMarkProgressView.totalPage = self.ranges.count
                    self.scrollViewDidScroll(self.collectionView)
                    
                }
                DispatchQueue.main.async {
                    if let item = self.textFileData?.bookmark{
                        let indexPath = IndexPath(item: Int(item), section: 0)
                        self.collectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.bottom, animated: false)
                        
                    }
                    
                }
            }
            
            
        })
     
    }
    
}

extension TextViewerViewController : UIScrollViewDelegate {
    func setUpBookMark(){
        view.addSubview(bookMarkView)
        bookMarkView.snp.makeConstraints { (make) in
            make.height.equalTo(40)
            make.width.equalTo(60)
            bookMarkTopConstraint = make.centerY.equalTo(view.snp.top).offset(20 + bookMarkMargin).constraint
            make.trailing.equalTo(view)
        }
        let panGestureRecognizer = UIPanGestureRecognizer(target:self, action: #selector(panGestureRecognizerAction))
        bookMarkView.addGestureRecognizer(panGestureRecognizer)
        view.addSubview(bookMarkProgressView)
        bookMarkProgressView.snp.makeConstraints { (make) in
            make.height.width.equalTo(100)
            make.center.equalTo(view)
        }
        view.addSubview(textLoadingProgressView)
        
    }
    @objc func panGestureRecognizerAction(gesture : UIPanGestureRecognizer){
        func getRange(minimumOffset : CGFloat, maximumOffset : CGFloat, offset : CGFloat) -> CGFloat{
            return min( max( minimumOffset, offset) , maximumOffset )
        }
        let translation = gesture.translation(in: view)
       
        if gesture.state == .began {
            bookMarkProgressView.isHidden = false
            bookMarkViewOriginY = bookMarkView.frame.origin.y + bookMarkView.frame.height / 2
        }
        guard let bookMarkViewOriginY = bookMarkViewOriginY  else {
            return
        }
      
        let offset =
            getRange(minimumOffset: bookMarkView.frame.height / 2 + bookMarkMargin, maximumOffset: view.frame.height - bookMarkView.frame.height / 2 - bookMarkMargin, offset: translation.y + bookMarkViewOriginY)
        let scrollOffset = (offset - bookMarkView.frame.height / 2 - bookMarkMargin) / (view.frame.height - bookMarkView.frame.height - bookMarkMargin * 2)
        
        collectionView.contentOffset = CGPoint(x: collectionView.contentOffset.x, y: (collectionView.contentSize.height - view.frame.height) * scrollOffset)
        if gesture.state == .ended {
            self.bookMarkViewOriginY = nil
            self.bookMarkProgressView.isHidden = true
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let count = ranges.count
        if (count != 0 && count != 1){
            let offset = view.frame.height - bookMarkView.frame.height - bookMarkMargin * 2
            let currentIndex = (collectionView.contentOffset.y / view.frame.height)
            
            let indexPath = IndexPath(item: Int(currentIndex), section: 0)
            bookMarkView.index = indexPath
            bookMarkProgressView.index = indexPath
            bookMarkTopConstraint?.update(offset:  offset * CGFloat(currentIndex) / CGFloat(count-1) + bookMarkView.frame.height / 2 + bookMarkMargin)
        }
    }
}

extension TextViewerViewController : UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func setUpCollectionView(){
        if #available(iOS 11, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        view.addSubview(collectionView)
        collectionView.register(TextViewerCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.snp.makeConstraints { (make) in
                        make.top.equalTo(topLayoutGuide.snp.bottom)
                        make.bottom.equalTo(bottomLayoutGuide.snp.top)
                        make.trailing.leading.equalTo(view)
//            make.top.bottom.trailing.leading.equalTo(view)
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.ranges.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
extension TextViewerViewController {
    func setUpTapNavigationBarSettings(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(collectionBarTapped))
        collectionView.addGestureRecognizer(tapGestureRecognizer)
    }
    @objc func collectionBarTapped(_ sender : Any){
        guard let nc = self.navigationController else {
            return
        }
     
        UIView.animate(withDuration: 0.5) {
            nc.setNavigationBarHidden(!nc.isNavigationBarHidden, animated: false)
            nc.setToolbarHidden(!nc.isToolbarHidden, animated: false)
            self.bookMarkView.alpha = 1 - self.bookMarkView.alpha
            self.view.layoutIfNeeded()
        }
    }
}
extension TextViewerViewController : UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! TextViewerCell
//        let textView = UITextView(frame: CGRect.zero, textContainer: textContainers[indexPath.item])
//        textView.isScrollEnabled = false
//        cell.addSubview(textViews[indexPath.item])
//        textViews[indexPath.item].snp.makeConstraints { (make) in
//            make.top.bottom.leading.trailing.equalTo(cell)
//        }
        if let string = string {
            let NSRange = ranges[indexPath.item]
            print(NSRange)
            print(string.length)
            let substring = string.attributedSubstring(from: NSRange)
            cell.textView.attributedText = substring
        }
//        cell.textView.attributedText = subStrings[indexPath.item]
        cell.index = indexPath
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        print(view.frame.height)
//        print(collectionView.frame.height)
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
}
extension TextViewerViewController : UISearchBarDelegate {
    @objc func searchText(){
//        toolbar.items = searchToolBarItems
        searchBar.isHidden = false
        searchBar.becomeFirstResponder()
    }
    @objc func searchPrevious(_ sender : Any){
        let text = searchBar.text ?? ""
        searchTextInRange(text: text, isNext: false)
    }
    @objc func searchNext(_ sender : Any){
        let text = searchBar.text ?? ""
        searchTextInRange(text: text, isNext: true)
    }
    func setUpSearchBar(){
        self.navigationController?.navigationBar.addSubview(searchBar)
        searchBar.snp.makeConstraints { (make) in
            make.top.trailing.leading.bottom.equalTo((self.navigationController?.navigationBar)!)
        }

    }
    func searchTextInRange(text : String, isNext : Bool){
        guard let previousRange = searchRange, let attributedString = string else {
            return
        }
        let nextRange : NSRange
        let range : NSRange
        if (isNext){
            nextRange = NSRange.init(location: previousRange.location + 1, length: attributedString.length - previousRange.location - 1)
            range = attributedString.mutableString.range(of: text, options: [], range: nextRange)
            
        }else{
            nextRange = NSRange.init(location: 0, length: previousRange.location)
            range = attributedString.mutableString.range(of: text, options: [NSString.CompareOptions.backwards], range: nextRange)
            
        }
       
        guard range != NSRange(location: NSNotFound, length: 0)  else {
            print("TODO : NOT FOUND!!")
            return
        }
        var finalIndex : Int?
        for (index, element) in ranges.enumerated(){
            if NSLocationInRange(range.lowerBound, element)    {
                finalIndex = index
                break
            }
        }
        guard let index = finalIndex else {
            return
        }
        
        searchRange = range
        attributedString.removeAttribute(NSAttributedStringKey.backgroundColor, range: previousRange)
        attributedString.addAttribute(NSAttributedStringKey.backgroundColor, value: UIColor.red, range: range)
        //        string?.addAttribute(NSAttributedStringKey.backgroundColor : UIColor.red, range: range)
        let indexPath = IndexPath(item: index, section: 0)
        DispatchQueue.main.async {
            //            self.collectionView.reloadItems(at: [indexPath])
            self.collectionView.reloadData()
            self.collectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.bottom, animated: true)
            
        }
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
       
        let text = searchBar.text ?? ""
        
        guard let attributedString = string else {
            return
        }
//        guard let range = attributedString.string.range(of: text) else {
//            return
//        }

        let range = attributedString.mutableString.range(of: text)
        
        
        guard range != NSRange(location: NSNotFound, length: 0)  else {
            print("TODO : NOT FOUND!!")
            return
        }
         toolbar.items = searchToolBarItems
//        let intValue = attributedString.string.distance(from: attributedString.string.startIndex, to: range.lowerBound)
        
        
        var finalIndex : Int?
        for (index, element) in ranges.enumerated(){
            if NSLocationInRange(range.lowerBound, element)    {
                finalIndex = index
                break
            }
        }
        guard let index = finalIndex else {
            return
        }
       
       searchRange = range
        string?.addAttribute(NSAttributedStringKey.backgroundColor, value: UIColor.red, range: range)
//        string?.addAttribute(NSAttributedStringKey.backgroundColor : UIColor.red, range: range)
        let indexPath = IndexPath(item: index, section: 0)
        DispatchQueue.main.async {
//            self.collectionView.reloadItems(at: [indexPath])
            self.collectionView.reloadData()
            self.collectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.bottom, animated: true)

        }
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.isHidden = true
        toolbar.items = defaultToolBarItems
    }
    
}
extension TextViewerViewController : UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    func documentInteractionControllerViewForPreview(_ controller: UIDocumentInteractionController) -> UIView? {
        return self.view
    }
    func documentInteractionControllerRectForPreview(_ controller: UIDocumentInteractionController) -> CGRect {
        return self.view.frame
    }
}

extension StringProtocol where Index == String.Index {
    func index<T: StringProtocol>(of string: T, options: String.CompareOptions = []) -> Index? {
        return range(of: string, options: options)?.lowerBound
    }
    func endIndex<T: StringProtocol>(of string: T, options: String.CompareOptions = []) -> Index? {
        return range(of: string, options: options)?.upperBound
    }
    func indexes<T: StringProtocol>(of string: T, options: String.CompareOptions = []) -> [Index] {
        var result: [Index] = []
        var start = startIndex
        while start < endIndex, let range = range(of: string, options: options, range: start..<endIndex) {
            result.append(range.lowerBound)
            start = range.lowerBound < range.upperBound ? range.upperBound : index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
    func ranges<T: StringProtocol>(of string: T, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var start = startIndex
        while start < endIndex, let range = range(of: string, options: options, range: start..<endIndex) {
            result.append(range)
            start = range.lowerBound < range.upperBound  ? range.upperBound : index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}
