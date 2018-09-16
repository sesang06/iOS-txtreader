//
//  OptionsViewController.swift
//  iOS-txtreader
//
//  Created by 조세상 on 2018. 9. 10..
//  Copyright © 2018년 조세상. All rights reserved.
//

import Foundation
import UIKit
import MessageUI
class OptionsViewController : UITableViewController , MFMailComposeViewControllerDelegate {
    let options : [String] = ["저장 공간 관리" , "정보",  "설정" ,"내 계정", "도움말" , "제작자 정보", "문의하기", "프로그램 정보" ]
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
        case 5:
            let vc = DeveloperInfoViewController()
            let uv = UINavigationController(rootViewController: vc)
            self.present(uv, animated: true) {
                self.revealViewController().revealToggle(self)
            }
            break
        case 6:
            sendMail()
        case 7:
            let vc = ProgramInfoViewController()
            let uv = UINavigationController(rootViewController: vc)
            self.present(uv, animated: true) {
                self.revealViewController().revealToggle(self)
            }
            break
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func sendMail(){
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
            print("can send mail")
        } else {
       //     self.showSendMailErrorAlert()
        }
        
    }
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients(["sesang06@naver.com"])
        mailComposerVC.setSubject("버그 리포트")
        mailComposerVC.setMessageBody("", isHTML: false)
        
        return mailComposerVC
    }
    
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "메일을 전송 실패", message: "아이폰 이메일 설정을 확인하고 다시 시도해주세요.", delegate: self, cancelButtonTitle: "확인")
        sendMailErrorAlert.show()
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
}

