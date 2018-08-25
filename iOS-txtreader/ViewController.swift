//
//  ViewController.swift
//  iOS-txtreader
//
//  Created by 조세상 on 2018. 8. 23..
//  Copyright © 2018년 조세상. All rights reserved.
//
import UIKit
import Foundation
import SnapKit


class ViewController: UIViewController {
    lazy var collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        cv.dataSource = self
        cv.delegate = self
        cv.isPagingEnabled = true
        return cv
    }()
    var largeString : String?
    let cellId = "cellId"
    var streamReader : StreamReader?
    lazy var attributes :  [NSAttributedStringKey : Any] = {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 5
        let attributes : [NSAttributedStringKey : Any] = [NSAttributedStringKey.paragraphStyle : style, NSAttributedStringKey.font : UIFont(name: "NanumGothic", size: 20)!]
        return attributes
    }()
    var stringReader : StringReader?
    let amount = 300
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        loadText()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func setUpView(){
        view.addSubview(collectionView)
        collectionView.register(TextViewCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(topLayoutGuide.snp.bottom)
            make.bottom.equalTo(bottomLayoutGuide.snp.top)
            make.trailing.leading.equalTo(view)
        }
    }
    func loadText(){
        guard let url = Bundle.main.url(forResource:"text", withExtension: "txt") else {
            return
        }
      
        let text = try? String(contentsOfFile: url.path, encoding: String.Encoding.utf8)
        
        largeString = text
        
        //streamReader = StreamReader(url: url)
        print(view.frame.size)
        let size = CGSize(width: view.frame.width, height: view.frame.height - 64)
        stringReader = StringReader(url: url, attributes: attributes, frame: size)
        DispatchQueue.global(qos: .background).async {
            
            let index = self.stringReader?.indice
            DispatchQueue.main.async {
         
                self.collectionView.reloadData()
                
            }
        }
    }

}
extension ViewController : UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stringReader?.indice.count ?? 0
//        return ((largeString?.count)! / amount) ?? 0
        //return streamReader?.totalPage(amount: amount) ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension ViewController : UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! TextViewCell
//        cell.backgroundColor = UIColor.red
//        if let string = streamReader?.nextContent(offset: indexPath.item, amount: amount) {
//            cell.displayText(string: string)
//        }
//        if let str = largeString {
//            let start = str.index(str.startIndex, offsetBy: indexPath.item * amount)
//            let end = str.index(str.startIndex, offsetBy: (indexPath.item + 1) * amount)
//
//            let range = start..<end
//
//            let substring = str[range]
//            let temp = String(substring)
//            cell.displayText(string: temp)
//        }
        if let str = stringReader?.pageContent(index: indexPath.item) {
             cell.displayText(string: str)
        }
       cell.backgroundColor = .red
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        print(view.frame.height)
        print(collectionView.frame.height)
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
}




