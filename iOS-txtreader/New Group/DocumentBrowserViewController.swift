//
//  DocumentBrowserViewController.swift
//  td
//
//  Created by 조세상 on 2018. 8. 26..
//  Copyright © 2018년 조세상. All rights reserved.
//

import UIKit
import SnapKit
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
    
    var filteredContents : [TextDocument]?
    var documentType : DocumentBrowserViewType = .Local
    let documentInteractionController = UIDocumentInteractionController()
    lazy var tableView : UITableView = {
        let tv = UITableView()
        tv.delegate = self
        tv.dataSource = self
        return tv
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
    let searchController = UISearchController(searchResultsController: nil)
    override func viewDidLoad() {
        super.viewDidLoad()
       
        setUpViews()
        setUpDocuments()
        setUpEditToolbar()
        
    }
    var isMain : Bool? {
        didSet{
            if (isMain == true) {
                setUpOptionsView()
            }
        }
    }
    func setUpOptionsView(){
        if let revealVC = self.revealViewController() {
            let btn = UIBarButtonItem()
            btn.image = UIImage(named: "baseline_menu_black_24pt")
            btn.target = revealVC
            btn.action = #selector(revealVC.revealToggle(_:))
            self.navigationItem.leftBarButtonItem = btn
            self.view.addGestureRecognizer(revealVC.panGestureRecognizer())
            self.view.addGestureRecognizer(revealVC.tapGestureRecognizer())

        }
        
    }
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    @objc func navBarTapped(){
        let vc = DocumentOptionsViewController()
        vc.modalPresentationStyle = .popover
        let popOver = vc.popoverPresentationController
        popOver?.sourceView = self.navigationItem.titleView
        popOver?.sourceRect = self.navigationItem.titleView!.bounds
        
        popOver?.permittedArrowDirections = [.up]
        popOver?.delegate = self
        vc.delegate = self
        DispatchQueue.main.async {
            self.present(vc, animated: true) {
                
            }
        }
    }
    func setUpSearchBar(){
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = true
        searchController.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        
        if #available(iOS 9.1, *) {
            searchController.obscuresBackgroundDuringPresentation = false
        } else {
            // Fallback on earlier versions
        }
        
        
    }
    func setUpViews(){
        self.navigationItem.rightBarButtonItems = [createBrowserBarButtonItem, editBrowserBarButtonItem]
        setUpTableView()
        setUpSearchBar()
    }
    func setUpEditToolbar(){
     
        toolbarItems = [
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
            ,
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.trash, target: self, action: #selector(deleteDocument))
            ,
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
            ,
            UIBarButtonItem(image : UIImage(named: "rename_file"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(changeDocumentName)),
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
            ,
            UIBarButtonItem(image : UIImage(named: "copy_file"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(copyDocument)),
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
            ,
            UIBarButtonItem(title: "파일 이동", style: UIBarButtonItemStyle.plain, target: self, action: #selector(moveDocument)),
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
            ,
            
            exportBarButton
           , UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
            
        ]
         enableToolbarButtons()
    }
    let exportBarButton =  UIBarButtonItem(image : UIImage(named: "export_file"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(importDocument))
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
        navigationController?.setToolbarHidden(false, animated: true)
        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        }
    }
    @objc func cancelEditBrowser(){
        
        tableView.setEditing(false, animated: true)
    self.navigationItem.setRightBarButtonItems([createBrowserBarButtonItem,editBrowserBarButtonItem], animated: true)
        navigationController?.setToolbarHidden(true, animated: true)
        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        }
        enableToolbarButtons()
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
    
    // copy document
    //TODO : appropriate animation!!
    @objc func copyDocument(){
        guard let indexPaths = tableView.indexPathsForSelectedRows else {
            return
        }
        for indexPath in indexPaths {
            guard let content = contents?[indexPath.item] else {
                break
            }
            guard let newPath = content.fileURL.newFileURL else {
                break
            }
            do {
                try FileManager.default.copyItem(at: content.fileURL, to: newPath)
             }catch let error as NSError {
                print(error.localizedDescription)
            }
        }
     
        let newContents = indexPaths.compactMap { (indexPath) -> TextDocument? in
          
            guard let content = contents?[indexPath.item] else {
                return nil
            }
            guard let newPath = content.fileURL.newFileURL else {
                return nil
            }
            do {
                try FileManager.default.copyItem(at: content.fileURL, to: newPath)
                let newContent = TextDocument(fileURL: newPath)
                return newContent
            }catch let error as NSError {
                print(error.localizedDescription)
                return nil
            }
            
        }
        contents?.insert(contentsOf: newContents, at: 0)
        let items = Array(0..<newContents.count).map{ IndexPath(row: $0, section: 0) }

        DispatchQueue.main.async {
            self.tableView.setEditing(false, animated: true)
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: items, with: UITableViewRowAnimation.automatic)
            self.tableView.endUpdates()
        }
    }
    @objc func moveDocument(){
        let vc = DocumentFileMoveViewController()
        vc.delegate = self
        let nc = UINavigationController(rootViewController: vc)
        nc.modalPresentationStyle = .popover
        let popOver = nc.popoverPresentationController
        popOver?.sourceView = self.view
        popOver?.sourceRect = self.view.frame
        popOver?.delegate = self
        popOver?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
//        print(popOver?.permittedArrowDirections)
        
        nc.preferredContentSize = CGSize(width:300, height: 300)
        DispatchQueue.main.async {
            self.present(nc, animated: true) {
                
            }
        }
    }

    @objc func importDocument(){
        guard let indexPath = tableView.indexPathForSelectedRow else {
            return
        }
        guard let selectedContent = contents?[indexPath.item] else {
            return
        }
        DispatchQueue.main.async {
            self.documentInteractionController.url = selectedContent.fileURL
            self.documentInteractionController.delegate = self
            self.documentInteractionController.presentOpenInMenu(from: self.exportBarButton, animated: true)
        }
        
    }
    func setUpDocuments(){
        switch documentType {
        case .Local:
            guard let dirPath = dirPath else {
                return
            }
            let directoryContents = try! FileManager.default.contentsOfDirectory(at: dirPath, includingPropertiesForKeys: [], options: [.skipsHiddenFiles, .skipsPackageDescendants, .skipsSubdirectoryDescendants])
            
            contents  = directoryContents.sorted(by: { x, y in
                return x.lastPathComponent.localizedStandardCompare(y.lastPathComponent) == ComparisonResult.orderedAscending
            }).map { (url) -> TextDocument in
                
                let document = TextDocument(fileURL: url)
                return document
            }
            let label = UILabel()
            label.text = dirPath.lastPathComponent
            label.font = UIFont.systemFont(ofSize: 20)
            self.navigationItem.titleView = label
            label.sizeToFit()
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
            label.sizeToFit()
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
    }
    
}
extension DocumentBrowserViewController {
    func enableToolbarButtons(){
        let count = tableView.indexPathsForSelectedRows?.count ?? 0
        toolbarItems?[1].isEnabled = (count > 0) ? true : false
        toolbarItems?[3].isEnabled = (count == 1) ? true : false
        toolbarItems?[5].isEnabled = (count > 0) ? true : false
        toolbarItems?[7].isEnabled = (count > 0) ? true : false
        toolbarItems?[9].isEnabled = (count == 1) ? true : false

    }
}
extension DocumentBrowserViewController : UITableViewDelegate {
    func setUpTableView(){
        self.extendedLayoutIncludesOpaqueBars = true
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
//            make.top.equalTo(topLayoutGuide.snp.bottom)
//            make.bottom.equalTo(bottomLayoutGuide.snp.top)
            make.top.bottom.equalTo(view)
            make.trailing.leading.equalTo(view)
        }
        tableView.register(DocumentBrowerCell.self, forCellReuseIdentifier: cellId)
        let footerView = UIView()
        footerView.backgroundColor = .clear
        tableView.tableFooterView = footerView
        
    }
    func tableView(_ tableView: UITableView,
                   shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool{
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let content = isFiltering() ? filteredContents?[indexPath.item] : contents?[indexPath.item]
        if (!tableView.isEditing){
            
            if (content?.isFolder == true){
                let vc = DocumentBrowserViewController()
                vc.dirPath = content?.fileURL
                self.navigationController?.pushViewController(vc, animated: true)
            }else{
                let textViewController = TextViewerViewController()
                textViewController.content = content
                self.navigationController?.pushViewController(textViewController, animated: true)
            }
            self.tableView.deselectRow(at: indexPath, animated: false)
        }else{
            enableToolbarButtons()
        }
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if (tableView.isEditing){
            enableToolbarButtons()
        }
    }
}
extension DocumentBrowserViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering(){
            return filteredContents?.count ?? 0
        }
        
        return contents?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! DocumentBrowerCell
        if isFiltering() {
            cell.content = filteredContents?[indexPath.item]
        }else {
            cell.content = contents?[indexPath.item]
        }
        return cell
    }
}
//북마크, 검색, 내보내기, 주/야간 설정

extension DocumentBrowserViewController : UISearchResultsUpdating {
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }

    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    func filterContentForSearcyText(_ searchText : String){
        filteredContents = contents?.filter{
            $0.fileName?.contains(searchText) ?? false
        }
        tableView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearcyText(searchController.searchBar.text!)
    }
}
extension DocumentBrowserViewController : UIDocumentInteractionControllerDelegate {
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

extension DocumentBrowserViewController : DocumentFileMoveViewControllerDelegate {
    func documentFileMoveViewDidClicked(documentFileMoveViewController: DocumentFileMoveViewController, url: URL) {
       
        documentFileMoveViewController.dismiss(animated: true) {
            self.tableView.indexPathsForSelectedRows?.forEach {
                if let at = self.contents?[$0.item].fileURL {
                    do {
                        try FileManager.default.moveItem(at: at, to: url.appendingPathComponent(at.lastPathComponent))
                        
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                }
            }
            self.contents?.remove(at: self.tableView.indexPathsForSelectedRows?.map{$0.item} ?? [])
            
            DispatchQueue.main.async {
                self.tableView.beginUpdates()
                self.tableView.deleteRows(at: self.tableView.indexPathsForSelectedRows ?? [], with: UITableViewRowAnimation.automatic)
                self.tableView.endUpdates()
            }
        }
       
    }
    
    
}
