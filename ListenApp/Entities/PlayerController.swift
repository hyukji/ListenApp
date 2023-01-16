//
//  PlayerClass.swift
//  ListenApp
//
//  Created by 곽지혁 on 2023/01/16.
//

import Foundation
import AVFoundation

class PlayerController {
    var player : AVAudioPlayer!
    var audio : Audio?
    
    var timeInterval = 5.0
    var isProgressBarInited = false
    
    func configurePlayer(url : URL) {
        do {
            print(url)
            player = try AVAudioPlayer(contentsOf: url)
            playPlayer()
            
        } catch {
            print("Error: Audio File missing.")
        }
    }
    
    func playPlayer() {
        player.prepareToPlay()
//        try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
//        try AVAudioSession.sharedInstance().setActive(true)
//        player.prepareToPlay()
        player.play()
//        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(), userInfo: nil, repeats: true)
    }
    
    func stopPlayer() {
        player.stop()
        // timer.inval
    }
    
    func pausePlayer() {
        player.stop()
        player.currentTime = 0
        
        // timer.inval
    }
    
}
