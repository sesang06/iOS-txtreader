//
//  DocumentOptionsViewController.swift
//  iOS-txtreader
//
//  Created by 조세상 on 2018. 9. 8..
//  Copyright © 2018년 조세상. All rights reserved.
//

import Foundation
import UIKit
enum DocumentBrowserViewType {
    case Local
    case Recent
    case Bookmark
    case ICloud
}
protocol DocumentOptionsViewControllerDelegate : class {
    func optionsViewDidClicked(documentOptionsViewController : DocumentOptionsViewController , type : DocumentBrowserViewType)
}
class DocumentOptionsViewController : UITableViewController {
    let cellId = "cellId"
    weak var delegate : DocumentOptionsViewControllerDelegate?
    override func viewDidLoad() {
        self.preferredContentSize = CGSize(width: 500, height: 44 * 4)

        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        self.tableView.isScrollEnabled = false
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for : indexPath) as! UITableViewCell
     
        let text : String
        switch (indexPath.item){
        case 0 : text = "local".localized
        case 1 : text = "recent".localized
        case 2 : text = "bookmark".localized
        case 3 : text = "iCloud".localized
        default : text = ""
        }
        cell.textLabel?.text = text
        return cell
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let type : DocumentBrowserViewType
        switch (indexPath.item){
        case 0 : type = .Local
        case 1 : type = .Recent
        case 2 : type = .Bookmark
        case 3 : type = .ICloud
        default : type = .Local
        }
      
        self.tableView.deselectRow(at: indexPath, animated: true)
        delegate?.optionsViewDidClicked(documentOptionsViewController: self, type: type)
    }
    
}
