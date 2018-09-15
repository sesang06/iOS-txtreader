//
//  DocumentFileMoveViewController.swift
//  iOS-txtreader
//
//  Created by 조세상 on 2018. 9. 15..
//  Copyright © 2018년 조세상. All rights reserved.
//  파일을 옮길 때 쓰는 컨트롤러

import UIKit
class DocumentFileMoveViewController : UITableViewController {
    let cellId = "cellId"
    var contents : [URL]?
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
        
        contents = try! fileManager.contentsOfDirectory(at: dirPath!, includingPropertiesForKeys: nil, options: [.skipsSubdirectoryDescendants, .skipsPackageDescendants, .skipsHiddenFiles]).filter{
             $0.hasDirectoryPath
            }
        tableView.reloadData()
        
    }
//    func getSubDirectories(rootDirectory : URL) -> [URL]{
//
//        
//        let enumerator = FileManager.default.enumerator(at: documentsURL,
//                                                        includingPropertiesForKeys: resourceKeys,
//                                                        options: [.skipsHiddenFiles], errorHandler: { (url, error) -> Bool in
//                                                            print("directoryEnumerator error at \(url): ", error)
//                                                            return true
//        })!
//        
//        for case let fileURL as URL in enumerator {
//            let resourceValues = try fileURL.resourceValues(forKeys: Set(resourceKeys))
//            print(fileURL.path, resourceValues.creationDate!, resourceValues.isDirectory!)
//        }
//        return subdirectories
//    }
 
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        cell.imageView?.image = UIImage(named: "outline_folder_black_48pt")
        cell.textLabel?.text = contents?[indexPath.item].lastPathComponent
        return cell
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contents?.count ?? 0
    }
 }
