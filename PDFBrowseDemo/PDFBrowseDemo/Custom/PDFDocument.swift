//
//  PDFDocument.swift
//  PDFBrowseDemo
//
//  Created by 杜进新 on 2018/7/20.
//  Copyright © 2018年 dujinxin. All rights reserved.
//

import UIKit
import CoreGraphics

struct PDFDoucment {
    /// Number of pages document contains
    public let pageCount: Int
    
    /// Name of the PDF file, used to display on navigation titles
    public let fileName: String
    
    /// File url where this document resides
    let fileURL: URL?
    
    /// File data of the document
    let fileData: Data
    
    /// Core Graphics representation of the document
    let coreDocument: CGPDFDocument
    
    /// Password of the document
    let password: String?
    
    /// Image cache with the page index and and image of the page
    let images = NSCache<NSNumber, UIImage>()
    
    /// Returns a newly initialized document which is located on the file system.
    ///
    /// - parameter url:      file or remote URL of the PDF document
    /// - parameter password: password for the locked PDF
    ///
    /// - returns: A newly initialized `PDFDocument`
    public init?(url: URL, password: String? = nil) {
        guard let fileData = try? Data(contentsOf: url) else { return nil }
        
        self.init(fileData: fileData, fileURL: url, fileName: url.lastPathComponent, password: password)
    }
    
    /// Returns a newly initialized document from data representing a PDF
    ///
    /// - parameter fileData: data of the PDF document
    /// - parameter fileName: name of the PDF file
    /// - parameter password: password for the locked pdf
    ///
    /// - returns: A newly initialized `PDFDocument`
    public init?(fileData: Data, fileName: String, password: String? = nil) {
        self.init(fileData: fileData, fileURL: nil, fileName: fileName, password: password)
    }
    
    /// Returns a newly initialized document
    ///
    /// - parameter fileData: data of the PDF document
    /// - parameter fileURL:  file URL where the PDF document exists on the file system
    /// - parameter fileName: name of the PDF file
    /// - parameter password: password for the locked PDF
    ///
    /// - returns: A newly initialized `PDFDocument`
    private init?(fileData: Data, fileURL: URL?, fileName: String, password: String?) {
        guard let provider = CGDataProvider(data: fileData as CFData) else { return nil }
        guard let coreDocument = CGPDFDocument(provider) else { return nil }
        
        self.fileData = fileData
        self.fileURL = fileURL
        self.fileName = fileName
        
        if let password = password, let cPasswordString = password.cString(using: .utf8) {
            // Try a blank password first, per Apple's Quartz PDF example
            if coreDocument.isEncrypted && !coreDocument.unlockWithPassword("") {
                // Nope, now let's try the provided password to unlock the PDF
                if !coreDocument.unlockWithPassword(cPasswordString) {
                    print("CGPDFDocumentCreateX: Unable to unlock \(fileName)")
                }
                self.password = password
            } else {
                self.password = nil
            }
        } else {
            self.password = nil
        }
        
        self.coreDocument = coreDocument
        self.pageCount = coreDocument.numberOfPages
    }
    
    
}
extension CGPDFPage {
    /// original size of the PDF page.
    var originalPageRect: CGRect {
        switch rotationAngle {
        case 90, 270:
            let originalRect = getBoxRect(.mediaBox)
            let rotatedSize = CGSize(width: originalRect.height, height: originalRect.width)
            return CGRect(origin: originalRect.origin, size: rotatedSize)
        default:
            return getBoxRect(.mediaBox)
        }
    }
}
