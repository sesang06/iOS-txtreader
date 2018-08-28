//
//  DocumentBrowserViewController.swift
//  td
//
//  Created by 조세상 on 2018. 8. 26..
//  Copyright © 2018년 조세상. All rights reserved.
//

import UIKit


class DocumentBrowserViewController: UIViewController {
    var document : TextDocument?
    var documentURL : URL?
    var contents : [TextDocument]?
    lazy var tableView : UITableView = {
        let tv = UITableView()
        tv.delegate = self
        tv.dataSource = self
        return tv
    }()
    let cellId = "cellId"
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        setUpDocuments()
    }
    func setUpViews(){
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(topLayoutGuide.snp.bottom)
            make.bottom.equalTo(bottomLayoutGuide.snp.top)
            make.trailing.leading.equalTo(view)
        }
        tableView.register(DocumentTableViewCell.self, forCellReuseIdentifier: cellId)
    }
    func setUpDocuments(){
        let fileManager = FileManager.default
        let dirPaths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        documentURL = dirPaths[0].appendingPathComponent("savetText.txt")
        document = TextDocument(fileURL: documentURL!)
        
        let directoryContents = try! FileManager.default.contentsOfDirectory(at: dirPaths[0], includingPropertiesForKeys: nil, options: [])
        contents  = directoryContents.map { (url) -> TextDocument in
            
            let document = TextDocument(fileURL: url)
            return document
        }
        tableView.reloadData()
        
        if fileManager.fileExists(atPath: (documentURL?.path)!){
            document?.open(completionHandler: { (success) in
                if success {
                    print("File open OK")
                    print("\(self.document?.text)")
                }else {
                    print("failed to open file")
                }
            })
        }else {
            document?.save(to: documentURL!, for: UIDocumentSaveOperation.forCreating, completionHandler: { (success) in
                if success {
                    print("file created OK")
                }else {
                    print("filed to create file")
                }
            })
        }
    }
    func saveDocument(){
        document!.text = "asdkfjasdkl;jf;lkajerlk;jasdlfkjlka;sgjkl;asjgflfk;sdjfla"
        document?.save(to: documentURL!, for: UIDocumentSaveOperation.forOverwriting, completionHandler: { (success) in
            if success {
                print("file override ok")
            }else {
                print("file overrite faile")
            }
        })
        
    }
    
}
extension DocumentBrowserViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let textViewController = OtherTextViewController()
        textViewController.content = contents?[indexPath.item]
        self.navigationController?.pushViewController(textViewController, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
extension DocumentBrowserViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contents?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! DocumentTableViewCell
        cell.content = contents?[indexPath.item]
        return cell
    }
}
