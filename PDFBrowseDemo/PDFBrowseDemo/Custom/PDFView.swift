//
//  PDFView.swift
//  PDFBrowseDemo
//
//  Created by 杜进新 on 2018/7/19.
//  Copyright © 2018年 dujinxin. All rights reserved.
//

import UIKit
import QuartzCore

class PDFView: UIView {

    var page : Int

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: 0, y: rect.height)
        context?.scaleBy(x: 1, y: -1)
        
        let name = "apple"
        let urlPath = Bundle.main.path(forResource: name, ofType: "pdf")
        if (FileManager.default.fileExists(atPath: urlPath!)) {
            print("文件存在")
            let path = urlPath?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            self.displayPDFPage(name: path!, pageNo: page, context: context!)
        }
    }
    init(frame: CGRect, pageNo: Int = 1) {
        page = pageNo
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getPDFDocument(name:String) -> CGPDFDocument? {
        let name1 = name as NSString
        //let a : UnsafePointer<Int8>
        print(name1)
        let fileName = CFStringCreateWithCString(kCFAllocatorDefault, name1.utf8String, CFStringBuiltInEncodings.UTF8.rawValue)
        print("path = ",fileName ?? "")
        guard let url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, fileName, CFURLPathStyle.cfurlposixPathStyle, false) else {
            print("获取文件URL失败")
            return nil
        }
        let document = CGPDFDocument.init(url)
        let count = document?.numberOfPages
        if count == 0 {
            return nil
        }
        print("获取PDF文件成功")
        return document
    }
    func displayPDFPage(name:String, pageNo:size_t, context:CGContext) {
        
        guard
            let document = getPDFDocument(name: name),
            let page = document.page(at: pageNo) else {
            return
        }
        context.drawPDFPage(page)
        print("绘制成功")
    }
}

