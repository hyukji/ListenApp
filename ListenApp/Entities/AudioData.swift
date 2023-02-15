//
//  Audio.swift
//  ListenApp
//
//  Created by 곽지혁 on 2023/01/12.
//

import UIKit

struct AudioData {
    let fileSystemFileNumber : Int
    let creationDate : Date
    var currentTime : TimeInterval
    let duration : Double
    let waveAnalysis : [Float]
    let sectionStart : [Int]
    let sectionEnd : [Int]
}
