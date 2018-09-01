//
//  DocumentBrowserViewController.swift
//  td
//
//  Created by 조세상 on 2018. 8. 26..
//  Copyright © 2018년 조세상. All rights reserved.
//

import UIKit


class DocumentBrowserViewController: UIViewController {
    var dirPath : URL?
    var contents : [TextDocument]?
    lazy var tableView : UITableView = {
        let tv = UITableView()
        tv.delegate = self
        tv.dataSource = self
        return tv
    }()
    lazy var editToolbar : UIToolbar = {
        let tb = UIToolbar()
        return tb
    }()
    lazy var editBrowserBarButtonItem : UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.edit, target: self, action: #selector(editBrowser))
        return button
    }()
    lazy var cancelEditBrowserBarButtoonItem : UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(self.cancelEditBrowser))
        return button
    }()
    lazy var createBrowserBarButtonItem : UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(self.createBrowser))
        return button
    }()
    let cellId = "cellId"
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        setUpDocuments()
        setUpEditToolbar()
    }
    func setUpViews(){
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(topLayoutGuide.snp.bottom)
            make.bottom.equalTo(bottomLayoutGuide.snp.top)
            make.trailing.leading.equalTo(view)
        }
        tableView.register(DocumentTableViewCell.self, forCellReuseIdentifier: cellId)
        self.navigationItem.rightBarButtonItems = [createBrowserBarButtonItem, editBrowserBarButtonItem]
        self.navigationItem.title = dirPath?.fileName
    }
    func setUpEditToolbar(){
        view.addSubview(editToolbar)
        editToolbar.items = [
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.trash, target: self, action: #selector(deleteDocument))
        ]
        editToolbar.snp.makeConstraints { (make) in
            make.bottom.leading.trailing.equalTo(view)
        }
    }
    @objc func deleteDocument(){
        tableView.indexPathsForSelectedRows?.forEach {
            if let url = contents?[$0.item].fileURL {
                do {
                    try FileManager.default.removeItem(at: url )

                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }
        }
        contents?.remove(at: tableView.indexPathsForSelectedRows?.map{$0.item} ?? [])
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.tableView.deleteRows(at: self.tableView.indexPathsForSelectedRows ?? [], with: UITableViewRowAnimation.automatic)
            self.tableView.endUpdates()
        }
      
    }
    
    @objc func editBrowser(){
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.setEditing(true, animated: true)
        self.navigationItem.setRightBarButtonItems([createBrowserBarButtonItem,cancelEditBrowserBarButtoonItem], animated: true)
       
    }
    @objc func cancelEditBrowser(){
        tableView.setEditing(false, animated: true)
        self.navigationItem.setRightBarButtonItems([createBrowserBarButtonItem,editBrowserBarButtonItem], animated: true)

       
    }
    //TODO :
    @objc func createBrowser(){
        self.showInputDialog(title: "createBroswerMessage".localized) { (input) in
            if let input = input {
                if input.count != 0, let fileURL = self.dirPath?.appendingPathComponent(input) {
                    if FileManager.default.fileExists(atPath: fileURL.path){
                        
                    }else{
                        do {  try FileManager.default.createDirectory(at: fileURL, withIntermediateDirectories: true, attributes: nil)
                            let document = TextDocument(fileURL: fileURL)
                            self.contents?.insert(document, at: 0)
                            let indexPath = IndexPath(item: 0, section: 0)
                            DispatchQueue.main.async {
                                self.tableView.beginUpdates()
                                self.tableView.insertRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                                self.tableView.endUpdates()
                            }
                           
                            
                        } catch {
                            
                        }
                    }
                }
            }
        }
    }
    func setUpDocuments(){
        guard let dirPath = dirPath else {
            return
        }
        
        
        let directoryContents = try! FileManager.default.contentsOfDirectory(at: dirPath, includingPropertiesForKeys: nil, options: [])
        contents  = directoryContents.map { (url) -> TextDocument in
            
            let document = TextDocument(fileURL: url)
            return document
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
//        if fileManager.fileExists(atPath: (documentURL?.path)!){
//            document?.open(completionHandler: { (success) in
//                if success {
//                    print("File open OK")
//                    print("\(self.document?.text)")
//                }else {
//                    print("failed to open file")
//                }
//            })
//        }else {
//            document?.save(to: documentURL!, for: UIDocumentSaveOperation.forCreating, completionHandler: { (success) in
//                if success {
//                    print("file created OK")
//                }else {
//                    print("filed to create file")
//                }
//            })
//        }
    }
//    func saveDocument(){
//        document!.text = "asdkfjasdkl;jf;lkajerlk;jasdlfkjlka;sgjkl;asjgflfk;sdjfla"
//        document?.save(to: documentURL!, for: UIDocumentSaveOperation.forOverwriting, completionHandler: { (success) in
//            if success {
//                print("file override ok")
//            }else {
//                print("file overrite faile")
//            }
//        })
//
//    }
    
}
extension DocumentBrowserViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (contents?[indexPath.item].isFolder == true){
            let vc = DocumentBrowserViewController()
            vc.dirPath = contents?[indexPath.item].fileURL
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            let textViewController = OtherTextViewController()
            textViewController.content = contents?[indexPath.item]
            self.navigationController?.pushViewController(textViewController, animated: true)
        }
    }
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
//    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
//        return UITableViewCellEditingStyle.insert
//    }
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
