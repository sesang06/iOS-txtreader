//
//  DocumentFileMoveViewController.swift
//  iOS-txtreader
//
//  Created by 조세상 on 2018. 9. 15..
//  Copyright © 2018년 조세상. All rights reserved.
//  파일을 옮길 때 쓰는 컨트롤러

import UIKit
struct Folder {
    let url : URL
    let level : Int
    init(url : URL , level : Int) {
        self.url = url
        self.level = level
    }
}
protocol DocumentFileMoveViewControllerDelegate : class {
    func documentFileMoveViewDidClicked(documentFileMoveViewController : DocumentFileMoveViewController, url : URL)
}
class DocumentFileMoveViewController : UITableViewController {
    let cellId = "cellId"
    weak var delegate : DocumentFileMoveViewControllerDelegate?
    var contents : [Folder]?
    override func viewDidLoad() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        let tableFooterView = UIView()
        tableFooterView.backgroundColor = .clear
        tableView.tableFooterView = tableFooterView
        self.navigationItem.title = "파일 이동"
        setUpFolders()
    }
    func setUpFolders(){
        let fileManager = FileManager.default
        let dirPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        getSubDirectories(rootDirectory: dirPath!)
    }
    func getSubDirectories(rootDirectory : URL) {

        let resourceKeys : [URLResourceKey] = [.creationDateKey, .isDirectoryKey]
        
        let enumerator = FileManager.default.enumerator(at : rootDirectory, includingPropertiesForKeys: resourceKeys,
            options: [.skipsHiddenFiles], errorHandler: { (url, error) -> Bool in
            print("directoryEnumerator error at \(url): ", error)
            return true
        })!
        contents = enumerator.compactMap { (content) -> Folder? in
            guard case let fileURL as URL = content else {
                return nil
            }
            guard fileURL.hasDirectoryPath else {
                return nil
            }
            return Folder(url: fileURL, level: enumerator.level)
        }
        contents?.insert(Folder(url: rootDirectory, level: 0), at: 0)
        tableView.reloadData()
    }
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        return contents?[indexPath.item].level ?? 0
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let url = contents?[indexPath.item].url else {
            return
        }
        delegate?.documentFileMoveViewDidClicked(documentFileMoveViewController: self, url: url)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        cell.imageView?.image = UIImage(named: "outline_folder_black_48pt")
        cell.textLabel?.text = contents?[indexPath.item].url.lastPathComponent
        return cell
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contents?.count ?? 0
    }
 }
