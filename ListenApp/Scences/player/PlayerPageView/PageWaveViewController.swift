//
//  PageWaveViewController.swift
//  ListenApp
//
//  Created by 곽지혁 on 2023/01/18.
//

import UIKit

class PageWaveViewController : UIViewController {
    
    lazy var imageView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "MusicBasic")
        imageView.contentMode = .scaleToFill
        imageView.frame.size.width = view.frame.width * 3
        imageView.frame.size.height = view.frame.height / 2
        
        return imageView
    }()
    
    lazy var scrollView : UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceHorizontal = true
        scrollView.showsHorizontalScrollIndicator = true
        
        scrollView.contentSize.width = imageView.frame.size.width
        
        scrollView.addSubview(imageView)
        
        return scrollView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLayout()

    }
}


extension PageWaveViewController {
    func setLayout(){
        
        [scrollView].forEach{
            view.addSubview($0)
        }
        
        scrollView.snp.makeConstraints{
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        
    }
}
