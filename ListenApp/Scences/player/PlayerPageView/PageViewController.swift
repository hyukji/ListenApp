//
//  PageViewController.swift
//  ListenTo
//
//  Created by 곽지혁 on 2023/01/11.
//

import UIKit

class PageViewController : UIViewController {
    
    var currentIndex = 0
    
    lazy var VCList: [UIViewController] = {
        let imageVC = PageImageViewController()
        let waveVC = PageWaveViewController()
        
        return [imageVC, waveVC]
    }()
    
    lazy var pageViewController : UIPageViewController = {
        let pageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        
        pageVC.dataSource = self
        pageVC.delegate = self
        
        if let firstVC = VCList.first {
            pageVC.setViewControllers([firstVC], direction: .forward, animated: true)
        }
        
        return pageVC
    }()
    
    private lazy var pageViewButtonList : [UIButton] = {
        let imgButton = UIButton()
        let waveButton = UIButton()
        
        imgButton.tag = 0
        waveButton.tag = 1
        
        let imgConfig = UIImage.SymbolConfiguration(font: .systemFont(ofSize: 20, weight: .semibold), scale: .default)
        let waveConfig = UIImage.SymbolConfiguration(font: .systemFont(ofSize: 20, weight: .semibold), scale: .default)
        
        imgButton.setImage(UIImage(systemName: "photo.fill", withConfiguration: imgConfig), for: .normal)
        waveButton.setImage(UIImage(systemName: "waveform", withConfiguration: waveConfig), for: .normal)
        
        imgButton.addTarget(self, action: #selector(tapPageControllerButton(_:)), for: .touchUpInside)
        waveButton.addTarget(self, action: #selector(tapPageControllerButton(_:)), for: .touchUpInside)
        
        return [imgButton, waveButton]
    }()
    
    private lazy var pageViewStackView : UIStackView = {
        let stackView = UIStackView()
        
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.tintColor = .secondaryLabel
        
        return stackView
    }()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChild(pageViewController)
        pageViewButtonList.forEach{
            pageViewStackView.addArrangedSubview($0)
        }
        changePageViewButton()
        
        setLayout()
        
    }
    
    func changePageViewButton(){
        for button in pageViewButtonList {
            if button.tag == currentIndex { button.tintColor = view.tintColor }
            else { button.tintColor = .secondaryLabel }
        }
    }
    
    @objc func tapPageControllerButton(_ sender: UIButton){
        let index = sender.tag
        
        if index == currentIndex { return }
        
        let direction = (index > currentIndex) ? UIPageViewController.NavigationDirection.forward : UIPageViewController.NavigationDirection.reverse
        currentIndex = index
        pageViewController.setViewControllers([VCList[index]], direction: direction, animated: true)
        changePageViewButton()
        
    }
    
    
}


private extension PageViewController {
    
    func setLayout(){
        
        [pageViewStackView, pageViewController.view].forEach{
            view.addSubview($0)
        }
        
        pageViewStackView.snp.makeConstraints{
            $0.centerX.equalToSuperview()
            $0.width.equalTo(70)
            $0.bottom.equalToSuperview().inset(10)
        }
        
        pageViewController.view.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview()
            $0.top.equalToSuperview().inset(30)
            $0.bottom.equalToSuperview().inset(60)
        }
    }
    
}





// pageVIewController
extension PageViewController : UIPageViewControllerDataSource, UIPageViewControllerDelegate {
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
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        guard let index = VCList.firstIndex(of: pendingViewControllers[0]) else {return}
        currentIndex = index
        changePageViewButton()
    }
}
