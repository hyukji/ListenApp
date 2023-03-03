//
//  StackViewSubViews.swift
//  ListenApp
//
//  Created by 곽지혁 on 2023/02/05.
//

import UIKit

extension UIStackView {
    
    func firstViewWidth() -> CGFloat {
        let imgView = arrangedSubviews[0] as! UIImageView
        return imgView.image!.size.width
    }
    
    func lastViewWidth() -> CGFloat {
        let cnt = arrangedSubviews.count
        let imgView = arrangedSubviews[cnt-1] as! UIImageView
        return imgView.image!.size.width
    }

    func popWaveImg() {
        let cnt = arrangedSubviews.count
        removeFully(view : arrangedSubviews[cnt-1])
    }
    
    func popLeftWaveImg() -> CGFloat {
        let view = arrangedSubviews[0] as! UIImageView
        removeFully(view : arrangedSubviews[0])
        
        return view.image?.size.width ?? 0
    }
    
    func appendWaveImg(view : UIImageView) {
        self.addArrangedSubview(view)
    }
    
    func appendLeftWaveImg(view : UIImageView) -> CGFloat {
        insertArrangedSubview(view, at: 0)
        return view.image?.size.width ?? 0
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
    
    func showAddSubViewsIdx() {
        var answer = "scrollStackView arr = "
        arrangedSubviews.forEach{
            answer += "\($0.tag) "
        }
        print(answer)
    }
    
    func changeWaveImage(WaveIdx : Int, view : UIImageView) {
        for i in 0..<arrangedSubviews.count {
            if arrangedSubviews[i].tag == WaveIdx {
                removeFully(view: arrangedSubviews[i])
                insertArrangedSubview(view, at: i)
            }
        }
    }
    
}
