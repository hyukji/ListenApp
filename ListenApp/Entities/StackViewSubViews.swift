//
//  StackViewSubViews.swift
//  ListenApp
//
//  Created by 곽지혁 on 2023/02/05.
//

import UIKit

class MyWaveImgStackView : UIStackView {
    
    var basicWaveViewArr : [UIImageView] = []
    var nowWaveViewArr : [UIImageView] = []

    func popWaveImg() {
        let cnt = arrangedSubviews.count
        removeFully(view : arrangedSubviews[cnt-1])
        basicWaveViewArr.remove(at: cnt-1)
        nowWaveViewArr.remove(at: cnt-1)
    }
    
    func popLeftWaveImg() -> CGFloat {
        let view = arrangedSubviews[0] as! UIImageView
        removeFully(view : arrangedSubviews[0])
        basicWaveViewArr.remove(at: 0)
        nowWaveViewArr.remove(at: 0)
        
        return view.image?.size.width ?? 0
    }
    
    func appendWaveImg(view : UIImageView, nowView : UIImageView) {
        self.addArrangedSubview(view)
        basicWaveViewArr.append(view)
        nowWaveViewArr.append(nowView)
    }
    
    func appendLeftWaveImg(view : UIImageView, nowView : UIImageView) -> CGFloat {
        insertArrangedSubview(view, at: 0)
        basicWaveViewArr.insert(view, at: 0)
        nowWaveViewArr.insert(nowView, at: 0)
        
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
        basicWaveViewArr = []
        nowWaveViewArr = []
    }
    
    func changeWaveImageForRepeat(WaveIdx : Int, view : UIImageView) {
        for i in 0..<arrangedSubviews.count {
            if arrangedSubviews[i].tag == WaveIdx {
                removeFully(view: arrangedSubviews[i])
                insertArrangedSubview(view, at: i)
            }
        }
    }
    
    func changeWithBasicArr(WaveIdx : Int) {
        for i in 0..<arrangedSubviews.count {
            if arrangedSubviews[i].tag == WaveIdx {
                removeFully(view: arrangedSubviews[i])
                insertArrangedSubview(basicWaveViewArr[i], at: i)
            }
        }
    }
    
    func changeWithNowArr(WaveIdx : Int) {
        for i in 0..<arrangedSubviews.count {
            if arrangedSubviews[i].tag == WaveIdx {
                removeFully(view: arrangedSubviews[i])
                insertArrangedSubview(nowWaveViewArr[i], at: i)
            }
        }
    }
    
}


// additional func for debugging
extension MyWaveImgStackView {
    
    func firstViewWidth() -> CGFloat {
        let imgView = arrangedSubviews[0] as! UIImageView
        return imgView.image!.size.width
    }
    
    func lastViewWidth() -> CGFloat {
        let cnt = arrangedSubviews.count
        let imgView = arrangedSubviews[cnt-1] as! UIImageView
        return imgView.image!.size.width
    }
    
    func showAddSubViewsIdx() {
        var answer = "scrollStackView arr = "
        arrangedSubviews.forEach{
            answer += "\($0.tag) "
        }
        print(answer)
    }
}
