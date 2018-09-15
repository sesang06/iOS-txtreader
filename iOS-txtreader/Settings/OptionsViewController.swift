//
//  OptionsViewController.swift
//  iOS-txtreader
//
//  Created by 조세상 on 2018. 9. 10..
//  Copyright © 2018년 조세상. All rights reserved.
//

import Foundation

class OptionsViewController : UITableViewController {
    let options : [String] = ["저장 공간 관리" , "정보",  "설정" ,"내 계정", "도움말" ]
    let settings : [String] = ["자동 정렬", "빈칸 삽입", "워드랩", "텍스트 인코딩", "줄 간격", "글자" ,"배경 색" , "마지막 페이지 이어보기", "상태바 표시", "안티앨리어스 사용", "여백", "글꼴", "숨김 파일 표시", ""]
    let cellId = "cellId"
    override func viewDidLoad() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        let footerView = UIView()
        footerView.backgroundColor = .clear
        tableView.tableFooterView = footerView
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        cell.textLabel?.text = options[indexPath.item]
        return cell
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 2:
            let textViewer = TextViewerSettingsViewController()
            let uv = UINavigationController(rootViewController: textViewer)
            self.present(uv, animated: true) {
                self.revealViewController().revealToggle(self)
            }
            break
        default:
            break
        }
    }
}

