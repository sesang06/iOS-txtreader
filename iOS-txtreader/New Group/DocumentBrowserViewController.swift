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
            self.setUpTitle()
        }
    }
    
   
}
class DocumentBrowserViewController: UIViewController , UIPopoverPresentationControllerDelegate {
    var dirPath : URL?
    var contents : [TextDocument]?
    
    var filteredContents : [TextDocument]?
    var documentType : DocumentBrowserViewType = .Local
    let documentInteractionController = UIDocumentInteractionController()
    // MARK: 새로고침을 위한..
    var shouldRefresh : Bool = false
    lazy var tableView : UITableView = {
        let tv = UITableView()
        tv.delegate = self
        tv.dataSource = self
        return tv
    }()
    // MARK: 우상단에 있는 버튼들..
    lazy var editBrowserBarButtonItem : UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.edit, target: self, action: #selector(editBrowser))
        return button
    }()
    lazy var cancelEditBrowserBarButtonItem : UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(self.cancelEditBrowser))
        return button
    }()
    lazy var createBrowserBarButtonItem : UIBarButtonItem = {
        let button = UIBarButtonItem(image : UIImage(named: "outline_create_new_folder_black_24pt"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.createBrowser))
        return button
    }()
    lazy var deleteRecentDocumentsBarButtonItem : UIBarButtonItem = {
        let button = UIBarButtonItem(image : UIImage(named: "outline_delete_sweep_black_24pt"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(deleteRecentDocuments))
        return button
    }()
    lazy var exportBarButton : UIBarButtonItem = {
      return UIBarButtonItem(image : UIImage(named: "outline_import_export_black_24pt"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(exportDocument))
    }()
    let cellId = "cellId"
    lazy var searchController : UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.delegate = self
        return sc
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
       
        setUpViews()
        setUpEditToolbar()
        
    }
    var isMain : Bool? {
        didSet{
            if (isMain == true) {
                setUpOptionsView()
            }
        }
    }
  
    
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
   
    
    func setUpViews(){
        self.navigationItem.rightBarButtonItems = [createBrowserBarButtonItem, editBrowserBarButtonItem]
        setUpTableView()
        setUpSearchBar()
        setUpTitle()
    }
   
    
    func setUpTitle(){
        switch documentType {
        case .Local:
            let label = UIButton(type: UIButtonType.custom)
            label.setTitle(dirPath?.lastPathComponent, for: .normal)
            label.sizeToFit()
            label.setTitleColor(UIColor.black, for: .normal)
            if (isMain == true){
                label.setImage(UIImage(named: "outline_keyboard_arrow_down_black_18pt"), for: .normal)
                label.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -10)
                label.semanticContentAttribute = UISemanticContentAttribute.forceRightToLeft
            }
            self.navigationItem.titleView = label
            self.navigationItem.setRightBarButtonItems([createBrowserBarButtonItem,editBrowserBarButtonItem], animated: true)
            break
        case .Recent:
            let label = UIButton(type: UIButtonType.custom)
            label.setTitle("recent".localized, for: .normal)
            label.sizeToFit()
            label.setTitleColor(UIColor.black, for: .normal)
            if (isMain == true){
                label.setImage(UIImage(named: "outline_keyboard_arrow_down_black_18pt"), for: .normal)
                label.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -10)
                label.semanticContentAttribute = UISemanticContentAttribute.forceRightToLeft
            }
            label.sizeToFit()
            self.navigationItem.titleView = label
            self.navigationItem.setRightBarButtonItems([deleteRecentDocumentsBarButtonItem], animated: true)
            break
        default:
            break
        }
        if (isMain == true){
            self.navigationItem.titleView?.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target:self, action: #selector(navBarTapped))
            self.navigationItem.titleView?.addGestureRecognizer(tap)
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
           
            break
        case .Recent:
             let textDatas = TextFileDAO.default.fetchRecent()
            contents = textDatas?.compactMap { (textData) -> TextDocument? in
               
                guard let urlString = textData.fileURL else {
                    return nil
                }
                let fileURL =  URL(fileURLWithPath: urlString)
                    
//                print(fileURL)
                guard FileManager.default.fileExists(atPath: fileURL.path) == true else {
                    TextFileDAO.default.delete(textData.objectID!)
                    return nil
                }
                let document = TextDocument(fileURL: fileURL, encoding: textData.encoding)
                return document
               
            }
           
            break
        default:
            break
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    deinit {
        self.searchController.view.removeFromSuperview()
    }
    
}
extension DocumentBrowserViewController {
    // MARK: 드로워뷰 설정
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
}
extension DocumentBrowserViewController {
    // MARK: 네비게이션 타이틀바 설정
    @objc func navBarTapped(){
        if (!isFiltering() && !tableView.isEditing){
            let vc = DocumentOptionsViewController()
            vc.modalPresentationStyle = .popover
            let popOver = vc.popoverPresentationController
            popOver?.sourceView = self.navigationItem.titleView
            popOver?.sourceRect = self.navigationItem.titleView!.bounds
            
            popOver?.permittedArrowDirections = [.up]
            popOver?.delegate = self
            vc.delegate = self
           
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.5, animations: {
                    if let button = self.navigationItem.titleView as? UIButton, let imageView = button.imageView {
                        let angle =  CGFloat(Double.pi)
                        let tr = CGAffineTransform.identity.rotated(by: angle)
                        imageView.transform = tr
                    }
                })
                self.present(vc, animated: true) {
                    
                }
            }
        }
    }
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, animations: {
                if let button = self.navigationItem.titleView as? UIButton, let imageView = button.imageView {
                    let angle =  CGFloat(Double.pi * 2)
                    let tr = CGAffineTransform.identity.rotated(by: angle)
                    imageView.transform = tr
                }
            })
        }
        return true
    }
}
extension DocumentBrowserViewController {
    // MARK: 툴바의 움직임 조정
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
            UIBarButtonItem(image : UIImage(named: "outline_file_copy_black_24pt"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(copyDocument)),
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
    @objc func editBrowser(){
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.setEditing(true, animated: true)
        self.navigationItem.setRightBarButtonItems([createBrowserBarButtonItem,cancelEditBrowserBarButtonItem], animated: true)
        navigationController?.setToolbarHidden(false, animated: true)
        setEnableSearchBar(false)
        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        }
    }
    @objc func cancelEditBrowser(){
        
        tableView.setEditing(false, animated: true)
        self.navigationItem.setRightBarButtonItems([createBrowserBarButtonItem,editBrowserBarButtonItem], animated: true)
        navigationController?.setToolbarHidden(true, animated: true)
        setEnableSearchBar(true)
        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        }
        
        enableToolbarButtons()
    }
}

extension DocumentBrowserViewController {
    // MARK: 수정, 삭제 등등
    
    
    // MARK: 생성
    @objc func createBrowser(){
        guard let dirPath = dirPath else {
            return
        }
        
        self.showInputDialog(title: "createBroswerMessage".localized) { (input) in
           
            guard let input = input else {
                return
            }
            guard !input.isEmpty else {
                return
            }
            let newURL = dirPath.appendingPathComponent(input)
            guard !FileManager.default.fileExists(atPath: newURL.path) else {
                self.showAlert(title: "오류", message: "\(input) 폴더가 이미 있습니다.", completion: {
                    
                })
                return
            }
            do {
                try FileManager.default.createDirectory(at: newURL, withIntermediateDirectories: true, attributes: nil)
                let document = TextDocument(fileURL: newURL)
                self.contents?.insert(document, at: 0)
                let indexPath = IndexPath(item: 0, section: 0)
                DispatchQueue.main.async {
                    self.tableView.beginUpdates()
                    self.tableView.insertRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                    self.tableView.endUpdates()
                }
                
                
            } catch let error as NSError {
                print(error.localizedDescription)
                self.showAlert(title: "오류", message: error.localizedDescription, completion: {
                })
            }
        }
    }
    // MARK: 이름 변경
    @objc func changeDocumentName(){
        guard let indexPath = tableView.indexPathForSelectedRow, var contents = contents, let dirPath = dirPath else {
            return
        }
        
        
        let selectedContent = contents[indexPath.item]
        self.showInputDialog(title: "changeDocumentNameMessage".localized,  defaultText: selectedContent.fileName , confirm : { (input) in
            guard let input = input else {
                return
            }
            guard !input.isEmpty else {
                return
            }
            let newURL = dirPath.appendingPathComponent(input)
            
            guard !FileManager.default.fileExists(atPath: newURL.path) else {
                self.showAlert(title: "오류", message: "\(input) 파일이 이미 있습니다.", completion: {
                    
                })
                return
            }
            do {
                try FileManager.default.moveItem(at: selectedContent.fileURL, to: newURL)
                if let data = selectedContent.textFileData {
                    data.fileURL = newURL.path
                    TextFileDAO.default.update(data)
               }
                let document = TextDocument(fileURL: newURL)
                contents[indexPath.item] = document
                self.contents = contents
                DispatchQueue.main.async {
                    self.cancelEditBrowser()
                    self.tableView.beginUpdates()
                    self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                    self.tableView.endUpdates()
                }
            } catch let error as NSError {
                print(error.localizedDescription)
                self.showAlert(title: "오류", message: error.localizedDescription, completion: {
                })
            }
        })
    }
    // TODO: appropriate animation!!
    // MARK: 복사
    @objc func copyDocument(){
        guard let indexPaths = tableView.indexPathsForSelectedRows, var contents = contents else {
            return
        }
        
        let newContents = indexPaths.compactMap { (indexPath) -> TextDocument? in
            
            let content = contents[indexPath.item]
            guard let newPath = content.fileURL.newFileURL else {
                return nil
            }
            do {
                try FileManager.default.copyItem(at: content.fileURL, to: newPath)
                let newContent = TextDocument(fileURL: newPath)
                return newContent
            }catch let error as NSError {
                print(error.localizedDescription)
                self.showAlert(title: "오류", message: error.localizedDescription, completion: {
                })
                return nil
            }
            
        }
        
        contents.insert(contentsOf: newContents, at: 0)
        contents.sort(by: { x, y in
            return x.fileURL.lastPathComponent.localizedStandardCompare(y.fileURL.lastPathComponent) == ComparisonResult.orderedAscending
        })
        let items = newContents.compactMap { (content) -> IndexPath? in
            guard let item = contents.firstIndex(of: content) else {
                return nil
            }
            return IndexPath(item:  item, section: 0)
        }
        
        self.contents = contents
        //let items = Array(0..<newContents.count).map{ IndexPath(row: $0, section: 0) }
        
        DispatchQueue.main.async {
            self.cancelEditBrowser()
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: items, with: UITableViewRowAnimation.automatic)
            self.tableView.endUpdates()
        }
    }
    // MARK: 제거
    @objc func deleteDocument(){
        self.showAlert(title: "삭제", message: "정말 선택하신 파일들을 삭제하시겠습니까?") { (success) in
            if success {
                guard let indexPaths = self.tableView.indexPathsForSelectedRows, var contents = self.contents else {
                    return
                }
                
                let deletedIndexPaths = indexPaths.compactMap { (indexPath) -> IndexPath? in
                    let content = contents[indexPath.item]
                    let url = content.fileURL
                    do {
                        try FileManager.default.removeItem(at: url)
                        if let data = content.textFileData {
                            TextFileDAO.default.delete(data.objectID!)
                        }
                        return indexPath
                    } catch let error as NSError {
                        self.showAlert(title: "오류", message: error.localizedDescription, completion: {
                            
                        })
                        print(error.localizedDescription)
                        return nil
                    }
                }
                
                contents.remove(at: deletedIndexPaths.map{$0.item})
                self.contents = contents
                DispatchQueue.main.async {
                    self.cancelEditBrowser()
                    self.tableView.beginUpdates()
                    self.tableView.deleteRows(at: deletedIndexPaths, with: UITableViewRowAnimation.automatic)
                    self.tableView.endUpdates()
                }
            }
        }
        
       
        
    }
    // MARK: 파일 경로 이동
    func moveDocuments(url : URL){
        guard let indexPaths = tableView.indexPathsForSelectedRows, var contents = contents else {
            return
        }
        let movedIndexPaths = indexPaths.compactMap { (indexPath) -> IndexPath? in
            let content = contents[indexPath.item]
            let at = content.fileURL
            do {
                let to =  url.appendingPathComponent(at.lastPathComponent)
                try FileManager.default.moveItem(at: at, to: to)
                
                if let data = content.textFileData {
                    data.fileURL = to.path
                    TextFileDAO.default.update(data)
                }
                return indexPath
            } catch let error as NSError {
                self.showAlert(title: "오류", message: error.localizedDescription, completion: {
                    
                })
//                print(error.localizedDescription)
                return nil
            }
        }
       
        contents.remove(at: movedIndexPaths.map{$0.item})
        self.contents = contents
        
        DispatchQueue.main.async {
            self.cancelEditBrowser()
            self.tableView.beginUpdates()
            self.tableView.deleteRows(at: movedIndexPaths, with: .automatic)
            self.tableView.endUpdates()
        }
        reload()
    }
    // MARK: 최근 도큐먼트 제거
    @objc func deleteRecentDocuments(){
        self.showAlert(title: "최신 도큐먼트 삭제", message: "최신 도큐먼트를 삭제하시겠습니까?") { (success) in
            guard success == true else {
                return
            }
            guard TextFileDAO.default.deleteAll() == true else {
                return
            }
            self.setUpDocuments()
        }
    }
}
extension DocumentBrowserViewController {
    // MARK: 새로고침을 할 필요가 있을 때..
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpDocuments()
        
        //        reloadDocument()
    }
    func reloadDocument(){
        if (shouldRefresh){
            shouldRefresh = false
            setUpDocuments()
        }
    }
    
    func reload(){
        guard let nc = self.navigationController else {
            return
        }
        for viewController in nc.viewControllers {
            switch viewController {
            case let documentBrowserViewController as DocumentBrowserViewController :
                documentBrowserViewController.shouldRefresh = true
                break
            default:
                break
            }
        }
    }
    
}
extension DocumentBrowserViewController : DocumentFileMoveViewControllerDelegate {
    // MARK: 이동
    func documentFileMoveViewDidClicked(documentFileMoveViewController: DocumentFileMoveViewController, url: URL) {
        documentFileMoveViewController.dismiss(animated: true) {
           self.moveDocuments(url: url)
        }
    }
    
}

extension DocumentBrowserViewController {
    // MARK:  파일 이동, 임포트
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
    
    @objc func exportDocument(_ sender : UIBarButtonItem){
//        print("import")
        guard let indexPath = tableView.indexPathForSelectedRow else {
            return
        }
        guard let selectedContent = contents?[indexPath.item] else {
            return
        }
        DispatchQueue.main.async {
            self.documentInteractionController.url = selectedContent.fileURL
            
            self.documentInteractionController.delegate = self
//        self.documentInteractionController.presentPreview(animated: true)
//            self.documentInteractionController.presentOptionsMenu(from: self.exportBarButton, animated: true)
            self.documentInteractionController.presentOpenInMenu(from: sender, animated: true)
//            self.documentInteractionController.presentOpenInMenu(from: self.view.frame, in: self.view, animated: true)
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
        tableView.cellLayoutMarginsFollowReadableWidth = false
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
            if filteredContents?.count == 0 {
                self.tableView.setEmptyMessage("검색 결과 없음")
            } else {
                self.tableView.restore()
            }
            
            return filteredContents?.count ?? 0
        }
        
        if contents?.count == 0 {
            self.tableView.setEmptyMessage("파일 없음")
        } else {
            self.tableView.restore()
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


extension DocumentBrowserViewController {
    // MARK: 검색창 설정
    func setUpSearchBar(){
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = true
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.searchBarStyle = UISearchBarStyle.minimal
        definesPresentationContext = true
        
        if #available(iOS 9.1, *) {
            searchController.obscuresBackgroundDuringPresentation = false
        } else {
            // Fallback on earlier versions
        }
    }
    func setEnableSearchBar(_ enabled: Bool){
       
        if (enabled){
            searchController.searchBar.isUserInteractionEnabled = true
//            searchController.searchBar.searchBarStyle = UISearchBarStyle.default
//            searchController.searchBar.backgroundColor = .clear
            searchController.searchBar.alpha = 1
        }else {
            searchController.searchBar.isUserInteractionEnabled = false
//            searchController.searchBar.searchBarStyle = UISearchBarStyle.minimal
            searchController.searchBar.alpha = 0.5
        }
    }
}
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


extension DocumentBrowserViewController : UISearchControllerDelegate {
    func willPresentSearchController(_ searchController: UISearchController) {
        self.navigationItem.setRightBarButtonItems(nil, animated: true)
    }
    func willDismissSearchController(_ searchController: UISearchController) {
    self.navigationItem.setRightBarButtonItems([createBrowserBarButtonItem,editBrowserBarButtonItem], animated: true)
        
    }
}


extension UITableView {
    
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
        messageLabel.sizeToFit()
        
        self.backgroundView = messageLabel;
        self.separatorStyle = .none;
    }
    
    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}
