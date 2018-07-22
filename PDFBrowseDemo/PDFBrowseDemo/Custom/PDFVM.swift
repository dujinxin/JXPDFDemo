//
//  PDFVM.swift
//  PDFBrowseDemo
//
//  Created by 杜进新 on 2018/7/20.
//  Copyright © 2018年 dujinxin. All rights reserved.
//

import UIKit

class PDFVM: NSObject {
    
    let imageWidth = UIScreen.main.bounds.size.width
    let imageHeigth = UIScreen.main.bounds.size.height - 88

    var images = NSCache<NSNumber, UIImage>()
    
    var document : PDFDoucment
    
    init(_ dc:PDFDoucment) {
        document = dc
        super.init()
    }

    /// Extracts image representations of each page in a background thread and stores them in the cache
    func loadPages() {
        DispatchQueue.global(qos: .background).async {
            for pageNumber in 1...self.document.pageCount {
                self.imageFromPDFPage(at: pageNumber, callback: { image in
                    guard let image = image else { return }
                    self.images.setObject(image, forKey: NSNumber(value: pageNumber))
                })
            }
        }
    }
    
    /// Image representations of all the document pages background thread
    func loadAllPageImages(callback: @escaping ([UIImage]) -> Void) {
        var images = [UIImage]()
        var pagesCompleted = 0
        DispatchQueue.global(qos: .background).async {
            for pageNumber in 0..<self.document.pageCount {
                self.pdfPageImage(at: pageNumber+1, callback: { (image) in
                    if let image = image {
                        images.append(image)
                    }
                    pagesCompleted += 1
                    if pagesCompleted == self.document.pageCount {
                        DispatchQueue.main.async {
                            callback(images)
                        }
                    }
                })
            }
        }
    }
    /// Image representations of all the document pages main thread
    func getAllPageImages(callback: ([UIImage]) -> Void) {
        var images = [UIImage]()
        var pagesCompleted = 0
        for pageNumber in 0..<self.document.pageCount {
            self.pdfPageImage(at: pageNumber+1, callback: { (image) in
                if let image = image {
                    images.append(image)
                }
                pagesCompleted += 1
                if pagesCompleted == self.document.pageCount {
                    callback(images)
                }
            })
        }
    }
    
    /// Image representation of the document page, first looking at the cache, calculates otherwise
    ///
    /// - parameter pageNumber: page number index of the page
    /// - parameter callback: callback to execute when finished
    ///
    /// - returns: Image representation of the document page
    func pdfPageImage(at pageNumber: Int, callback: (UIImage?) -> Void) {
        if let image = images.object(forKey: NSNumber(value: pageNumber)) {
            callback(image)
        } else {
            imageFromPDFPage(at: pageNumber, callback: { image in
                guard let image = image else {
                    callback(nil)
                    return
                }
                
                images.setObject(image, forKey: NSNumber(value: pageNumber))
                callback(image)
            })
        }
    }
    
    /// Grabs the raw image representation of the document page from the document reference
    ///
    /// - parameter pageNumber: page number index of the page
    /// - parameter callback: callback to execute when finished
    ///
    /// - returns: Image representation of the document page
    private func imageFromPDFPage(at pageNumber: Int, callback: (UIImage?) -> Void) {
        guard let page = self.document.coreDocument.page(at: pageNumber) else {
            callback(nil)
            return
        }
        UIImage.drawImage(to: CGSize(width: imageWidth, height: imageHeigth), pdfPage: page, comletion: callback)
    }
}
