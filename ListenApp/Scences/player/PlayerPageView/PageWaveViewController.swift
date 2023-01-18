//
//  PageWaveViewController.swift
//  ListenApp
//
//  Created by 곽지혁 on 2023/01/18.
//

import UIKit
import DSWaveformImage

class PageWaveViewController : UIViewController {
    private let waveformImageDrawer = WaveformImageDrawer()
    private let audioURL = playerController.getDocumentFileURL()
    
    lazy var imageView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "MusicBasic")
        imageView.contentMode = .scaleToFill
        imageView.frame.size.width = view.frame.width * 3
        imageView.frame.size.height = 300
        
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
        
        
        waveformImageDrawer.waveformImage(
            fromAudioAt: audioURL, with: .init(
                size: imageView.frame.size,
                style: .striped(.init(color: view.tintColor)),
                dampening: .init(percentage: 0.2, sides: .left, easing: { x in pow(x, 4) }),
                verticalScalingFactor: 2)
        ) { image in
            // need to jump back to main queue
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        }
        
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
