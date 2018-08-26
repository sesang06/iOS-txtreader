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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let fileManager = FileManager.default
        let dirPaths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        documentURL = dirPaths[0].appendingPathComponent("savetText.txt")
        document = TextDocument(fileURL: documentURL!)
        
        let directoryContents = try! FileManager.default.contentsOfDirectory(at: dirPaths[0], includingPropertiesForKeys: nil, options: [])
  
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
