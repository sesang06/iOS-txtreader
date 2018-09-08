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


class OtherTextViewController: UIViewController, UITextViewDelegate {
    lazy var collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        cv.dataSource = self
        cv.delegate = self
        
        return cv
    }()

    lazy var scrollSize : CGSize = {
       let size = CGSize(width: view.frame.width, height: view.frame.height - 40 - 64)
        return size
    }()
    lazy var attributes :  [NSAttributedStringKey : Any] = {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 5
        let attributes : [NSAttributedStringKey : Any] = [NSAttributedStringKey.paragraphStyle : style, NSAttributedStringKey.font : UIFont(name: "NanumGothic", size: 20)!]
        return attributes
    }()
    weak var content : TextDocument?
    let cellId = "cellId"
    let bookMarkView = BookMarkView()
    var bookMarkTopConstraint : Constraint?

    var ranges : [NSRange] = [NSRange]()
    var string : NSAttributedString?
    var subStrings : [NSAttributedString] = [NSAttributedString]()
    
    var shapeLayer: CAShapeLayer!
    var pulsatingLayer: CAShapeLayer!
    var trackLayer : CAShapeLayer!
    var textFileData : TextFileData?
    var textFileDAO : TextFileDAO = TextFileDAO()
    let percentageLabel: UILabel = {
        let label = UILabel()
        label.text = "Start"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 32)
        label.textColor = .white
        return label
    }()
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
    }
    
    @objc private func handleEnterForeground() {
        animatePulsatingLayer()
    }
    
    private func createCircleShapeLayer(strokeColor: UIColor, fillColor: UIColor) -> CAShapeLayer {
        let layer = CAShapeLayer()
        let circularPath = UIBezierPath(arcCenter: .zero, radius: 100, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        layer.path = circularPath.cgPath
        layer.strokeColor = strokeColor.cgColor
        layer.lineWidth = 20
        layer.fillColor = fillColor.cgColor
        layer.lineCap = kCALineCapRound
        layer.position = view.center
        return layer
    }
    
    private func setupPercentageLabel() {
        view.addSubview(percentageLabel)
        percentageLabel.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        percentageLabel.center = view.center
    }
    
    private func setupCircleLayers() {
        pulsatingLayer = createCircleShapeLayer(strokeColor: .clear, fillColor: UIColor.pulsatingFillColor)
        view.layer.addSublayer(pulsatingLayer)
        animatePulsatingLayer()
        
        trackLayer = createCircleShapeLayer(strokeColor: .trackStrokeColor, fillColor: .backgroundColor)
        view.layer.addSublayer(trackLayer)
        
        shapeLayer = createCircleShapeLayer(strokeColor: .outlineStrokeColor, fillColor: .clear)
        
        shapeLayer.transform = CATransform3DMakeRotation(-CGFloat.pi / 2, 0, 0, 1)
        shapeLayer.strokeEnd = 0
        view.layer.addSublayer(shapeLayer)
    }
    
    private func animatePulsatingLayer() {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        
        animation.toValue = 1.5
        animation.duration = 0.8
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation.autoreverses = true
        animation.repeatCount = Float.infinity
        
        pulsatingLayer.add(animation, forKey: "pulsing")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNotificationObservers()
        
        setUpView()
        setupCircleLayers()
         setupPercentageLabel()
         fetchTextFileData()
        loadText()
       
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func fetchTextFileData(){
        let data = self.textFileDAO.fetch(fileURL: content?.fileURL)
        if data == nil {
            let data = TextFileData()
            data.bookmark = 0
            data.fileURL = content?.fileURL.path
            data.openDate = Date()
            self.textFileDAO.insert(data)
            self.textFileData = self.textFileDAO.fetch(fileURL: content?.fileURL)
        }else {
            self.textFileData = data
        }
    }
    func updateTextFileData(){
        let currentIndex = (collectionView.contentOffset.y / collectionView.frame.height)
        //            print(currentIndex)
        let indexPath = IndexPath(item: Int(currentIndex), section: 0)
        self.textFileData?.encoding = content?.encoding
        self.textFileData?.bookmark = Int64(indexPath.item)
        self.textFileDAO.update(self.textFileData!)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        updateTextFileData()
    }
    func setUpView(){

        view.addSubview(collectionView)
        collectionView.register(TextViewCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(topLayoutGuide.snp.bottom)
            make.bottom.equalTo(bottomLayoutGuide.snp.top)
            make.trailing.leading.equalTo(view)
        }
        view.addSubview(bookMarkView)
        bookMarkView.snp.makeConstraints { (make) in
            make.height.equalTo(40)
            make.width.equalTo(60)
            bookMarkTopConstraint = make.centerY.equalTo(topLayoutGuide.snp.bottom).offset(20).constraint
            make.trailing.equalTo(view)
        }
        let panGestureRecognizer = UIPanGestureRecognizer(target:self, action: #selector(panGestureRecognizerAction))
        bookMarkView.addGestureRecognizer(panGestureRecognizer)
        self.navigationItem.title = content?.fileName
    }
    func loadText(){
        let scrollSize = self.scrollSize
        shapeLayer.strokeEnd = 0
//        let fileManager = FileManager.default
//        let dirPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
//            print (content?.fileURL.relativePath)
//        print(content?.fileURL.baseURL)
//        let data = try! content?.fileURL.bookmarkData()
//        print(String(data: data!, encoding:.utf8 ))
      
        content?.open(completionHandler: { (success) in
            guard success else {
                return
            }
            guard  let text = self.content?.text  else {
                return
            }
           
            DispatchQueue.global(qos: .userInteractive).async {
                let attributedString = NSAttributedString(string: text , attributes: self.attributes)
                self.string = attributedString
                let textStorage = NSTextStorage(attributedString: attributedString)
                let textLayout = NSLayoutManager()
                textStorage.addLayoutManager(textLayout)
                
                //                let textContainer = NSTextContainer(size: self.view.frame.size)
                textLayout.allowsNonContiguousLayout = true
                //                textLayout.addTextContainer(textContainer)
                
                
                //                let size = CGSize(width : self.view.frame.width,  height : CGFloat.infinity)
                //                let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
                //
                //                let estimatedRect = attributedString.boundingRect(with: size, options: options, context: nil)
                
                //                self.count = Int(estimatedRect.size.height / self.scrollSize.height) + 1
                
                while(true){
                    let textContainer = NSTextContainer(size: scrollSize)
                    //                    self.textContainers.append(textContainer)
                    
                    textLayout.addTextContainer(textContainer)
                    //                    let textView = UITextView(frame: CGRect.zero, textContainer: textContainer)
                    //            let textView = UITextView(frame: CGRect(x: view.frame.size.width * CGFloat(i), y: 0, width: view.frame.size.width, height: view.frame.size.height), textContainer: textContainer)
                    //                    textView.tag = i
                    //                    textView.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0)
                    //                    textView.textContainer.lineFragmentPadding = 0
                    //                    textView.delegate = self
                    //                    //        textView.isScrollEnabled = false
                    //                    textView.isEditable = false
                    //                    textView.isPagingEnabled = true
                    //                    textView.attributedText = textString
                    //                    //            textView.isScrollEnabled = false
                    //                    //
                    //                    textViews.append(textView)
                    //                    // scrollview.addSubview(textView)
                    
                    let rangeThatFits = textLayout.glyphRange(forBoundingRect: .infinite, in: textContainer)
                    //                    print(rangeThatFits.location)
                    if (rangeThatFits.length == 0){
                        break
                    }
                    self.ranges.append(rangeThatFits)
                    
                    self.subStrings.append(attributedString.attributedSubstring(from: rangeThatFits))
                    
                    let percentage = CGFloat(rangeThatFits.upperBound) / CGFloat(attributedString.length)
                    DispatchQueue.main.async {
                        self.percentageLabel.text = "\(Int(percentage * 100))%"
                        self.shapeLayer.strokeEnd = percentage
                    }
                    //                    cell.textView.attributedText = substring
                    //                    print(rangeThatFits)
                    
                }
                DispatchQueue.main.async {
                    self.shapeLayer.isHidden = true
                    self.pulsatingLayer.isHidden = true
                    self.trackLayer.isHidden = true
                    self.percentageLabel.isHidden = true
                    self.collectionView.reloadData()
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
       

        
//        textView.snp.makeConstraints { (make) in
//            make.top.bottom.leading.trailing.equalTo(view)
//        }
    }
    var bookMarkViewOriginY : CGFloat?
    @objc func panGestureRecognizerAction(gesture : UIPanGestureRecognizer){
        let translation = gesture.translation(in: view)
        //   view.frame.origin.y = translation.y
        print(translation)
        if gesture.state == .began {
            bookMarkViewOriginY = bookMarkView.frame.origin.y + bookMarkView.frame.height / 2
        }
        guard let bookMarkViewOriginY = bookMarkViewOriginY  else {
            return
        }
        let offset = min( max(bookMarkView.frame.height / 2, translation.y + bookMarkViewOriginY ), collectionView.frame.height - bookMarkView.frame.height / 2)
        let scrollOffset = (offset - bookMarkView.frame.height / 2) / (collectionView.frame.height - bookMarkView.frame.height)
//        print(scrollOffset)
//        print((scrollview.contentSize.height - scrollview.frame.height) * scrollOffset)
        
        //        bookMarkTopConstraint?.update(offset: offset)
        collectionView.contentOffset = CGPoint(x: collectionView.contentOffset.x, y: (collectionView.contentSize.height - collectionView.frame.height) * scrollOffset)
        if gesture.state == .ended {
            self.bookMarkViewOriginY = nil
        }
    }
    deinit{
        content?.close(completionHandler: { (sucess) in
            
        })
    }

}

extension OtherTextViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        /*if*/ let count = ranges.count
            //{
        if (count != 0 && count != 1){
        let offset = collectionView.frame.height - bookMarkView.frame.height
            let currentIndex = (collectionView.contentOffset.y / collectionView.frame.height)
//            print(currentIndex)
            let indexPath = IndexPath(item: Int(currentIndex), section: 0)
            bookMarkView.index = indexPath
            bookMarkTopConstraint?.update(offset:  offset * CGFloat(currentIndex) / CGFloat(count-1) + bookMarkView.frame.height / 2)
        //        }
        }
    }
}

extension OtherTextViewController : UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
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

extension OtherTextViewController : UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! TextViewCell
//        let textView = UITextView(frame: CGRect.zero, textContainer: textContainers[indexPath.item])
//        textView.isScrollEnabled = false
//        cell.addSubview(textViews[indexPath.item])
//        textViews[indexPath.item].snp.makeConstraints { (make) in
//            make.top.bottom.leading.trailing.equalTo(cell)
//        }
//        if let string = string {
//            let NSRange = ranges[indexPath.item]
//            let substring = string.attributedSubstring(from: NSRange)
//            cell.textView.attributedText = substring
//        }
        cell.textView.attributedText = subStrings[indexPath.item]
        cell.index = indexPath
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        print(view.frame.height)
//        print(collectionView.frame.height)
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
}


