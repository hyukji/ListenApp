//
//  NowPlayingButton.swift
//  ListenTo
//
//  Created by 곽지혁 on 2023/01/10.
//

import UIKit

class NowPlayingButton : UIButton {
    
    var config : UIButton.Configuration = {
        var config = UIButton.Configuration.filled()
        
        config.baseBackgroundColor = .tintColor
        config.baseForegroundColor = .systemBackground
        
        var titleAttr = AttributedString.init("title 1")
        titleAttr.font = .systemFont(ofSize: 15, weight: .semibold)
        
        config.attributedTitle = titleAttr
        config.titleAlignment = .trailing
        
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 15, weight: .regular)
        config.image = UIImage(systemName: "play.fill", withConfiguration: imageConfig)
        config.imagePadding = 10
        config.imagePlacement = .leading
        
        config.buttonSize = .large
        
        
//        config.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
//        self.backgroundColor = .tintColor
//        self.layer.cornerRadius = 20
        
        
        return config
    }()
    
    
    
    override init(frame: CGRect) {
        super .init(frame: frame)
        
        setLayout()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
    



extension NowPlayingButton {
    
    private func setLayout() {
        
        self.configuration = config
        
    }
}

