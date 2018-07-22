//
//  CustomViewController.swift
//  PDFBrowseDemo
//
//  Created by 杜进新 on 2018/7/19.
//  Copyright © 2018年 dujinxin. All rights reserved.
//

import UIKit

class CustomViewController: UIViewController {
    
    var vm : PDFVM!
    
    var dataArray = Array<UIImage>()
    
    lazy var childVC: UIPageViewController = {
        //
        let options = [UIPageViewControllerOptionInterPageSpacingKey:0] as [String : Any]
        //翻页效果，从右向左
        let vc = UIPageViewController.init(transitionStyle: .pageCurl, navigationOrientation: .horizontal, options:options)
        vc.view.backgroundColor = UIColor.white
        vc.dataSource = self
        vc.delegate = self
        
        vc.isDoubleSided = false
        return vc
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addChildViewController(self.childVC)
        self.view.addSubview(self.childVC.view)
        self.childVC.didMove(toParentViewController: self)
        
        //File
        guard
            let path = Bundle.main.path(forResource: "iOS_SQLite", ofType: "pdf"),
            let document = PDFDoucment(url: URL(fileURLWithPath: path)) else {
                return
        }
//        guard
//            let url = URL(string: "http://devstreaming.apple.com/videos/wwdc/2016/201h1g4asm31ti2l9n1/201/201_internationalization_best_practices.pdf"),
//            let document = PDFDoucment(url: url) else {
//                return
//        }
        //URL
        self.vm = PDFVM.init(document)
        
        self.vm.loadAllPageImages { (images) in
            self.dataArray = images
            print(self.dataArray.count)
            if self.dataArray.count == 0 {
                return
            }
            DispatchQueue.main.async {
                let pdfVC = PDFViewController()
                pdfVC.view.backgroundColor = UIColor.white
                //pdfVC.pdfView = PDFView.init(frame: pdfVC.view.bounds, pageNo: 1)
                //pdfVC.view.addSubview(pdfVC.pdfView!)
                let image = self.dataArray[0]
                pdfVC.imageView = UIImageView()
                pdfVC.imageView?.image = image
                pdfVC.imageView?.frame = CGRect.init(x: 0, y: 0, width: image.size.width, height: image.size.height)
                pdfVC.view.addSubview(pdfVC.imageView!)
                pdfVC.imageView?.center = CGPoint(x: pdfVC.view.center.x, y: pdfVC.view.center.y - 44)
                
                self.childVC.setViewControllers([pdfVC], direction: .reverse, animated: false) { (isFinish) in
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func pdfViewController(at index: Int) -> UIViewController? {
        if self.dataArray.count == 0 || index >= self.dataArray.count {
            return nil
        } else {
            let image = self.dataArray[index]
            
            let pdfVC = PDFViewController()
            pdfVC.imageView = UIImageView()
            pdfVC.imageView?.image = image
            pdfVC.imageView?.frame = CGRect.init(x: 0, y: 0, width: image.size.width, height: image.size.height)
            pdfVC.view.addSubview(pdfVC.imageView!)
            pdfVC.imageView?.center = CGPoint(x: pdfVC.view.center.x, y: pdfVC.view.center.y - 44)
            
            return pdfVC
        }
    }
    func index(of viewController: PDFViewController) -> Int {
        guard
            let imageView = viewController.imageView, let image = imageView.image else {
                return NSNotFound
        }
        let index = self.dataArray.index(of: image)
        return index!
    }
}
extension CustomViewController: UIPageViewControllerDataSource,UIPageViewControllerDelegate{
    //MARK:UIPageViewControllerDataSource
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? PDFViewController else {
            return nil
        }
        var index = self.index(of: vc)
        if index == 0 || index == NSNotFound {
            return nil
        }
        index -= 1
        return self.pdfViewController(at: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? PDFViewController else {
            print("未找到viewController")
            return nil
        }
        var index = self.index(of: vc)
        if index == NSNotFound {
            print("未找到index")
            return nil
        }
        index += 1
        return self.pdfViewController(at: index)
    }
    
    //MARK:UIPageViewControllerDelegate
}
