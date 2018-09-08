//
//  DocumentBrowserViewController.swift
//  td
//
//  Created by 조세상 on 2018. 8. 26..
//  Copyright © 2018년 조세상. All rights reserved.
//

import UIKit

extension DocumentBrowserViewController : DocumentOptionsViewControllerDelegate {
    func optionsViewDidClicked(documentOptionsViewController: DocumentOptionsViewController, type: DocumentBrowserViewType) {
        documentOptionsViewController.dismiss(animated: true) {
            self.documentType = type
            self.setUpDocuments()
        }
    }
    
   
}
class DocumentBrowserViewController: UIViewController , UIPopoverPresentationControllerDelegate {
    var dirPath : URL?
    var contents : [TextDocument]?
    var documentType : DocumentBrowserViewType = .Local
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
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    @objc func navBarTapped(){
        let vc = DocumentOptionsViewController()
        vc.preferredContentSize = CGSize(width: 100, height: 100)
        vc.modalPresentationStyle = .popover
        let popOver = vc.popoverPresentationController
        popOver?.sourceView = self.navigationItem.titleView
        popOver?.sourceRect = self.navigationItem.titleView!.frame
        popOver?.permittedArrowDirections = [.up]
        popOver?.delegate = self
        vc.delegate = self
        self.present(vc, animated: true) {
            
        }
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
        
      
//        self.navigationItem.title = dirPath?.lastPathComponent
    }
    func setUpEditToolbar(){
        view.addSubview(editToolbar)
        editToolbar.items = [
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.trash, target: self, action: #selector(deleteDocument))
            ,
            UIBarButtonItem(title: "이름 변경", style: UIBarButtonItemStyle.plain, target: self, action: #selector(changeDocumentName)),
            
            UIBarButtonItem(title: "파일 복사", style: UIBarButtonItemStyle.plain, target: self, action: #selector(copyDocument)),
            UIBarButtonItem(title: "파일 이동", style: UIBarButtonItemStyle.plain, target: self, action: #selector(moveDocument)),
            
            UIBarButtonItem(title: "파일 임포트", style: UIBarButtonItemStyle.plain, target: self, action: #selector(importDocument))
        ]
        editToolbar.snp.makeConstraints { (make) in
            make.bottom.leading.trailing.equalTo(view)
        }
    }
    @objc func changeDocumentName(){
        guard let indexPath = tableView.indexPathForSelectedRow else {
            return
        }
        guard let selectedContent = contents?[indexPath.item] else {
            return
        }
        self.showInputDialog(title: "changeDocumentNameMessage".localized,  defaultText: selectedContent.fileName , confirm : { (input) in
            guard let input = input else {
                return
            }
            guard !input.isEmpty else {
                return
            }
            guard let newURL = self.dirPath?.appendingPathComponent(input) else{
                return
            }
            
            guard !FileManager.default.fileExists(atPath: newURL.path) else {
                return
            }
            do {
                try FileManager.default.moveItem(at: selectedContent.fileURL, to: newURL)
                let document = TextDocument(fileURL: newURL)
                self.contents?[indexPath.item] = document
                DispatchQueue.main.async {
                    self.tableView.beginUpdates()
                    self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                    self.tableView.endUpdates()
                }
            } catch {
                
            }
        })
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
    @objc func copyDocument(){
        
    }
    @objc func moveDocument(){
        
    }
    @objc func importDocument(){
        
    }
    func setUpDocuments(){
        switch documentType {
        case .Local:
            guard let dirPath = dirPath else {
                return
            }
            let directoryContents = try! FileManager.default.contentsOfDirectory(at: dirPath, includingPropertiesForKeys: nil, options: [])
            contents  = directoryContents.map { (url) -> TextDocument in
                
                let document = TextDocument(fileURL: url)
                return document
            }
            let label = UILabel()
            label.text = dirPath.lastPathComponent
            label.font = UIFont.systemFont(ofSize: 20)
            self.navigationItem.titleView = label
            break
        case .Recent:
            let textDatas = TextFileDAO.default.fetchRecent()
            contents = textDatas?.compactMap { (textData) -> TextDocument? in
                guard let urlString = textData.fileURL else {
                    return nil
                }
                let fileURL =  URL(fileURLWithPath: urlString)
                    
                print(fileURL)
                guard FileManager.default.fileExists(atPath: fileURL.path) == true else {
                    return nil
                }
                let document = TextDocument(fileURL: fileURL, encoding: textData.encoding)
                return document
               
            }
            let label = UILabel()
            label.text = "recent".localized
            label.font = UIFont.systemFont(ofSize: 20)
            self.navigationItem.titleView = label
            break
        default:
            break
        }
        
        self.navigationItem.titleView?.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target:self, action: #selector(navBarTapped))
        self.navigationItem.titleView?.addGestureRecognizer(tap)
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
        if (!tableView.isEditing){
            if (contents?[indexPath.item].isFolder == true){
                let vc = DocumentBrowserViewController()
                vc.dirPath = contents?[indexPath.item].fileURL
                self.navigationController?.pushViewController(vc, animated: true)
            }else{
                let textViewController = OtherTextViewController()
                textViewController.content = contents?[indexPath.item]
                self.navigationController?.pushViewController(textViewController, animated: true)
            }
            self.tableView.deselectRow(at: indexPath, animated: false)
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
