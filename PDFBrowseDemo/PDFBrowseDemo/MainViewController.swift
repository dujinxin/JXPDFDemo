//
//  MainViewController.swift
//  PDFBrowseDemo
//
//  Created by 杜进新 on 2018/7/19.
//  Copyright © 2018年 dujinxin. All rights reserved.
//

import UIKit
import QuickLook

class MainViewController: UIViewController {
    
    var urls = [URL]()    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let fileNames = ["apple","javaScript","mongodb"]
        for i in 0..<3 {
            let url = Bundle.main.url(forResource: fileNames[i], withExtension: "pdf")
            urls.append(url!)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func showPDFController(_ sender: UIButton) {
        let vc  = QLPreviewController.init()
        vc.delegate = self
        vc.dataSource = self
        self.present(vc, animated: true) {
            
        }
    }
    @IBAction func showCustomPDFController(_ sender: UIButton) {
        let vc = CustomViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
   
}
extension MainViewController : QLPreviewControllerDataSource,QLPreviewControllerDelegate{
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return urls.count
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        let item = urls[index] as QLPreviewItem
        return item
    }
}


