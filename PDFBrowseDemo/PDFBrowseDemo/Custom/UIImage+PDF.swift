//
//  UIImage+PDF.swift
//  PDFBrowseDemo
//
//  Created by 杜进新 on 2018/7/22.
//  Copyright © 2018年 dujinxin. All rights reserved.
//

import UIKit

extension UIImage {

    /// 绘制PDF图片
    ///
    /// - Parameters:
    ///   - scalingSize: 将要绘制图片的大小
    ///   - pdfPage: pdf单页文件
    ///   - comletion: 回调，返回当前绘制的图像
    static func drawImage(to scalingSize:CGSize,pdfPage:CGPDFPage,comletion:(_ image:UIImage?)->()) {
        
        let originalRect = pdfPage.originalPageRect
    
        let pdfScale = min(scalingSize.width/originalRect.width, scalingSize.height/originalRect.height)
        let scaledSize = CGSize(width: originalRect.width * pdfScale, height: originalRect.height * pdfScale)
        let scaledRect = CGRect(origin: originalRect.origin, size: scaledSize)
        
        UIGraphicsBeginImageContextWithOptions(scaledSize, true, 1)
        guard let context = UIGraphicsGetCurrentContext() else {
            comletion(nil)
            return
        }
        
        // First fill the background with white.
        context.setFillColor(UIColor.white.cgColor)
        context.fill(scaledRect)

        context.saveGState()
        
        // Flip the context so that the PDF page is rendered right side up.
        let rotationAngle: CGFloat
        switch pdfPage.rotationAngle {
        case 90:
            rotationAngle = 270
            context.translateBy(x: scaledSize.width, y: scaledSize.height)
        case 180:
            rotationAngle = 180
            context.translateBy(x: 0, y: scaledSize.height)
        case 270:
            rotationAngle = 90
            context.translateBy(x: scaledSize.width, y: scaledSize.height)
        default:
            rotationAngle = 0
            context.translateBy(x: 0, y: scaledSize.height)
        }
        
        context.scaleBy(x: 1, y: -1)
        //context.rotate(by: rotationAngle.degreesToRadians)
        
        // Scale the context so that the PDF page is rendered at the correct size for the zoom level.
        context.scaleBy(x: pdfScale, y: pdfScale)
        context.drawPDFPage(pdfPage)
        context.restoreGState()
        
        defer { UIGraphicsEndImageContext() }
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            comletion(nil)
            return
        }
        comletion(image)
    }
}
