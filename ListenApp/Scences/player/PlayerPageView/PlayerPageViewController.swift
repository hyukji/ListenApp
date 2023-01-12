//
//  PlayerPageViewController.swift
//  ListenTo
//
//  Created by 곽지혁 on 2023/01/11.
//

import UIKit

class PlayerPageViewController : UIPageViewController {
    
    private lazy var imageVC : UIViewController = {
        let VC = UIViewController()
        
        VC.view.backgroundColor = .red
        return VC
    }()
    
    private lazy var waveVC : UIViewController = {
        let VC = UIViewController()
        
        VC.view.backgroundColor = .blue
        return VC
    }()
    
    lazy var VCList: [UIViewController] = {
        let imageVC = UIViewController()
        let waveVC = UIViewController()
            
        imageVC.view.backgroundColor = .blue
        waveVC.view.backgroundColor = .red
        
        return [imageVC, waveVC]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        self.dataSource = self
        
        if let firstVC = VCList.first {
            self.setViewControllers([firstVC], direction: .forward, animated: true)
        }
    }
    
}


extension PlayerPageViewController : UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = VCList.firstIndex(of: viewController) else {return nil}
        let beforeIndex = index - 1
        if beforeIndex < 0 { return nil}
        
        return VCList[beforeIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = VCList.firstIndex(of: viewController) else {return nil}
        let afterIndex = index + 1
        if afterIndex == VCList.count { return nil}
        
        return VCList[afterIndex]
    }
    
    
    
    
}
