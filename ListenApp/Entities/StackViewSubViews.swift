//
//  StackViewSubViews.swift
//  ListenApp
//
//  Created by 곽지혁 on 2023/02/05.
//

import UIKit

extension UIStackView {
    
    func firstViewTag() -> Int {
        return arrangedSubviews[1].tag
    }
    
    func lastViewTag() -> Int {
        let cnt = arrangedSubviews.count
        return arrangedSubviews[cnt-2].tag
    }

    func popWaveImg() {
        let cnt = arrangedSubviews.count
        removeFully(view : arrangedSubviews[cnt-2])
    }
    
    func popLeftWaveImg() {
        removeFully(view : arrangedSubviews[1])
    }
    
    func appendWaveImg(view : UIImageView) {
        let cnt = arrangedSubviews.count
        insertArrangedSubview(view, at: cnt-1)
    }
    
    func appendLeftWaveImg(view : UIImageView) {
        insertArrangedSubview(view, at: 1)
    }

    func removeFully(view: UIView) {
        removeArrangedSubview(view)
        view.removeFromSuperview()
    }
    
    func removeFullySubviews() {
        arrangedSubviews.forEach{
            removeFully(view: $0)
        }
    }
    
}
