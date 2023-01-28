//
//  Audio.swift
//  ListenApp
//
//  Created by 곽지혁 on 2023/01/12.
//

import UIKit

struct AudioData {
    var title : String
    var folder : String
    let audioExtension : String
    
    let waveImage : UIImage
    
    let waveAnalysis : [Double]
    
    var currentTime : TimeInterval
    let duration : TimeInterval
    let creationDate : Date
}

