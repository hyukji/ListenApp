//
//  Audio.swift
//  ListenApp
//
//  Created by 곽지혁 on 2023/01/12.
//

import UIKit

struct NowAudio {
    let uuid : String = UUID().uuidString
    let waveImage : UIImage
    let mainImage : UIImage
    let title : String
    let currentTime : Double
    let AudioExtension : String?
}

