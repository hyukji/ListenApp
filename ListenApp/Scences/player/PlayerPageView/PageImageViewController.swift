//
//  PageImageViewController.swift
//  ListenApp
//
//  Created by 곽지혁 on 2023/01/18.
//

import UIKit


class PageImageViewController : UIViewController {
    
    private lazy var imgView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "MusicBasic")
        imageView.contentMode = .scaleAspectFill
        
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLayout()
        
    }
    
}

extension PageImageViewController {
    
    func setLayout() {
        view.addSubview(imgView)
        
        let size = min(view.frame.size.width, view.frame.size.height) - 100
        imgView.snp.makeConstraints{
            $0.centerX.centerY.equalToSuperview()
            $0.width.height.equalTo(size)
        }
        
    }
}
