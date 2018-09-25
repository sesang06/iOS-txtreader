//
//  ViewController.swift
//  iOS-txtreader
//
//  Created by 조세상 on 2018. 8. 23..
//  Copyright © 2018년 조세상. All rights reserved.
//
// 텍스트뷰를 통으로 집어넣는 것은 실패!
// TODO : navigation bar slide!!

import UIKit
import Foundation
import SnapKit


class TextViewerViewController: UIViewController, UITextViewDelegate{
  
    // MARK: 콜렉션 뷰
    let cellId = "cellId"
    
    lazy var collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.gray
        cv.dataSource = self
        cv.delegate = self
        cv.isPagingEnabled = true
        cv.showsVerticalScrollIndicator = false
        return cv
    }()
    
    
    // MARK: 텍스트뷰의 사이즈를 미리 계산함
    lazy var textViewSize : CGSize = {
       let size = CGSize(width: view.frame.width - 60, height: view.frame.height - 40 - 30)
        return size
    }()
    
    // MARK: 텍스트 로딩 중 인디케이터.
    lazy var textLoadingProgressView : TextLoadingProgressView = {
       let tlpv = TextLoadingProgressView(frame: view.frame)
        return tlpv
    }()
   
    
    // MARK: 북마크
    let bookMarkView = BookMarkView()
    var bookMarkViewOriginY : CGFloat?
    var bookMarkTopConstraint : Constraint?
    let bookMarkMargin : CGFloat = 64
    lazy var bookMarkProgressView : BookMarkProgressView = {
        let bmp = BookMarkProgressView()
        bmp.isHidden = true
        return bmp
    }()
    
    // MARK: 텍스트 저장정보
    var string : NSMutableAttributedString?
    var ranges : [NSRange] = [NSRange]()
    weak var content : TextDocument? {
        didSet{
            fetchTextFileData()
            setUpText()
            self.setHidesSearchBar(true, animated: false)
        }
    }
    
    // MARK: 검색할 때 필요
    var searchRange : NSRange?
    var searchString : String?
    
    lazy var searchBar : UISearchBar = {
        var searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.barStyle = .blackTranslucent
        return searchBar
    }()
    
    
    
    let documentInteractionController = UIDocumentInteractionController()
    
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(false, animated: false)
     
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
        self.view.backgroundColor = .gray
        setUpCollectionView()
        setUpBookMark()
        setUpTapNavigationBarSettings()
        setUpToolbar()
        
    }
    deinit{
        print("deinit")
        content?.close(completionHandler: { (sucess) in
        })
    }

}

extension TextViewerViewController {
    @objc func viewerMode(){
        switch (UserDefaultsManager.default.viewType ?? .normal){
        case .darcula:
            UserDefaultsManager.default.viewType = .normal
        case .normal:
            UserDefaultsManager.default.viewType = .darcula
        }
        if let attributedString = string {
            let range = NSRange.init(location: 0, length: attributedString.length)
            attributedString.setAttributes(UserDefaultsManager.default.attributes, range: range)
        }
        
        self.collectionView.reloadData()
    }
    @objc func exportText(){
        DispatchQueue.main.async {
            self.documentInteractionController.url = self.content?.fileURL
            self.documentInteractionController.delegate = self
            self.documentInteractionController.presentOptionsMenu(from: self.view.frame, in: self.view, animated: true)
        }
    }
    
    func setUpToolbar(){
        
        self.toolbarItems = defaultToolBarItems
        
    }
    
}

extension TextViewerViewController {
    
    override var prefersStatusBarHidden: Bool {
        return navigationController?.isNavigationBarHidden == true
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return UIStatusBarAnimation.slide
    }
    
    
}
extension TextViewerViewController {
    func fetchTextFileData(){
        guard let content = content else {
            return
        }
        guard (content.textFileData == nil) else {
            return
        }
        let data = TextFileData()
        data.bookmark = 0
        data.pages = 0
        data.fileURL = content.fileURL.path
        data.openDate = Date()
        TextFileDAO.default.insert(data)
        
    }
    func updateTextFileData(){
        guard let cell = collectionView.visibleCells.first else {
            return
            
        }
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        guard let data = self.content?.textFileData else {
            return
        }
        data.encoding = content?.encoding
        data.bookmark = Int64(indexPath.item)
        data.pages = Int64(ranges.count)
        TextFileDAO.default.update(data)
        
    }
    func loadBookmarkInfo(){
        if let item = self.content?.textFileData?.bookmark{
            let indexPath = IndexPath(item: Int(item), section: 0)
            
            if indexPath.item < self.ranges.count && indexPath.item >= 0{
                self.collectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.top, animated: false)
            }
        }
    }
    func setUpText(){
        let scrollSize = self.textViewSize
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
                [weak self] in
                
                let attributedString = NSMutableAttributedString(string: text , attributes: UserDefaultsManager.default.attributes)
                self?.string = attributedString
                let textStorage = NSTextStorage(attributedString: attributedString)
                let textLayout = NSLayoutManager()
                textStorage.addLayoutManager(textLayout)
                
                //                let textContainer = NSTextContainer(size: self.view.frame.size)
                textLayout.allowsNonContiguousLayout = true
                
                while(true){
                    if (self == nil) {
                        break
                    }
                    let textContainer = NSTextContainer(size: scrollSize)
                    
                    textLayout.addTextContainer(textContainer)
                 
                    
                    let rangeThatFits = textLayout.glyphRange(for: textContainer)
                    print(rangeThatFits.upperBound)
                    print(self?.string?.length)
                    //                    print(rangeThatFits.location)
                    if (rangeThatFits.upperBound >= attributedString.length){
                        let finalRange = NSMakeRange(rangeThatFits.location, attributedString.length - rangeThatFits.location)
                        self?.ranges.append(finalRange)
                        
                        break
                    }
                    self?.ranges.append(rangeThatFits)
                    
                    let percentage = CGFloat(rangeThatFits.upperBound) / CGFloat(attributedString.length)
                    self?.textLoadingProgressView.percentage = percentage
                  }
                DispatchQueue.main.async {
                    self?.textLoadingProgressView.isHidden = true
                    self?.collectionView.reloadData()
                    self?.bookMarkProgressView.totalPage = self?.ranges.count
                    if let collectionView = self?.collectionView{
                        self?.scrollViewDidScroll(collectionView)
                    }
                    self?.loadBookmarkInfo()
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
            self.bookMarkView.alpha = 1 - self.bookMarkView.alpha
            self.collectionView.showsVerticalScrollIndicator = !self.collectionView.showsVerticalScrollIndicator
            self.view.layoutIfNeeded()
        }
        nc.setNavigationBarHidden(!nc.isNavigationBarHidden, animated: true)
        nc.setToolbarHidden(!nc.isToolbarHidden, animated: true)
        
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
            let substring = string.attributedSubstring(from: NSRange)
            cell.textView.attributedText = substring
        }
        switch (UserDefaultsManager.default.viewType ?? .normal){
        case .darcula:
            cell.pageView.backgroundColor = UIColor.black
            cell.pageLabel.textColor = UIColor.white
            break
        case .normal:
            cell.pageView.backgroundColor = UIColor.white
            cell.pageLabel.textColor = UIColor.black
            break
        }
        cell.index = indexPath
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
}
extension TextViewerViewController : UISearchBarDelegate {
    @objc func searchText(){
//        toolbar.items = searchToolBarItems
       setHidesSearchBar(false, animated: true)
        
        searchBar.becomeFirstResponder()
    }
    @objc func searchPrevious(_ sender : Any){
        searchTextInRange(isNext: false)
    }
    @objc func searchNext(_ sender : Any){
        searchTextInRange(isNext: true)
    }
    
    private func searchBarDidBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    func setHidesSearchBar(_ hidesSearchBar : Bool, animated : Bool){
        if hidesSearchBar {
            let label = UILabel()
            label.text = content?.fileName
            self.navigationItem.titleView = label
            label.sizeToFit()
            self.navigationItem.setRightBarButton(nil, animated: animated)
            self.toolbarItems = defaultToolBarItems
            self.searchString = nil
            if let searchRange = self.searchRange {
                string?.removeAttribute(NSAttributedStringKey.backgroundColor, range: searchRange)
                collectionView.reloadData()
                self.searchRange = nil
            }
            
        }else {
            self.navigationItem.titleView = searchBar
            let hideSearchBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(hideSearchBar))
            self.navigationItem.setRightBarButton(hideSearchBarButton, animated: animated)
            
        }
        self.navigationItem.setHidesBackButton(!hidesSearchBar, animated: animated)
        
    }
    @objc func hideSearchBar(_ sender : Any){
        self.setHidesSearchBar(true, animated: true)
    }
    func searchTextInRange(isNext : Bool){
        guard let text = searchString else {
            return
        }
        
        guard let previousRange = searchRange, let attributedString = string else {
            return
        }
        let nextRange : NSRange
        let range : NSRange
        if (isNext){
            nextRange = NSRange.init(location: previousRange.location + 1, length: attributedString.length - previousRange.location - 1)
            range = attributedString.mutableString.range(of: text, options: [NSString.CompareOptions.caseInsensitive], range: nextRange)
            
        }else{
            nextRange = NSRange.init(location: 0, length: previousRange.location)
            range = attributedString.mutableString.range(of: text, options: [NSString.CompareOptions.backwards, NSString.CompareOptions.caseInsensitive], range: nextRange)
            
        }
       
        guard range != NSRange(location: NSNotFound, length: 0)  else {
            print("TODO : NOT FOUND!!")
            self.showAlert(title: "찾기", message: "\(text)는 찾을 수 없습니다.") {
                
            }
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
            self.collectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.top, animated: true)
            
        }
        
    }
    
    /**
     서치바 검색을 함
     이전 검색 저장함
     툴바를 바꿈
     **/
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        let text = searchBar.text ?? ""
        if let searchRange = self.searchRange {
            string?.removeAttribute(NSAttributedStringKey.backgroundColor, range: searchRange)
            collectionView.reloadData()
            self.searchRange = nil
        }
        
        searchString = text
        searchRange = NSRange.init(location: -1, length: 0)
        
        
        self.toolbarItems = searchToolBarItems
        searchTextInRange(isNext: true)
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.isHidden = true
        self.toolbarItems = defaultToolBarItems
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
