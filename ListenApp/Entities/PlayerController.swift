//
//  PlayerClass.swift
//  ListenApp
//
//  Created by 곽지혁 on 2023/01/16.
//

import Foundation
import AVFoundation

enum PlayerStatus {
    case play
    case pause
    case stop
    case intermit
}

class PlayerController {
    static let playerController = PlayerController()
    
    var player : AVAudioPlayer!
    var audio : AudioData?
    var url : URL?
    
    var status : PlayerStatus = .pause
    
    var timeInterval = 5.0
    var isNewAudio = false
    
    let changedAmountPerSec = 100.0
    
    private init() { }
    
    
    func configurePlayer(url : URL) {
        if !isNewAudio { return }
        if status == .play { stopPlayer() }
        
        do {
            isNewAudio = false
            player = try AVAudioPlayer(contentsOf: url)
        } catch {
            print("Error: Audio File missing.")
        }
    }
    
    func playPlayer() {
//        try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
//        try AVAudioSession.sharedInstance().setActive(true)
        player.prepareToPlay()
        player.play()
        
        status = .play

        NotificateTo()
    }
    
    func stopPlayer() {
        player.stop()
        player.currentTime = 0
        status = .stop
        
        NotificateTo()
    }
    
    func intermitPlayer() {
        player.pause()
        status = .intermit
        
        NotificateTo()
    }
    
    func pausePlayer() {
        player.pause()
        status = .pause
        
        NotificateTo()
    }
    
    func changePlayerTime(changedTime : TimeInterval) {
        player.currentTime = changedTime
        NotificateTo()
    }
    
    func NotificateTo() {
        NotificationCenter.default.post(
            name: Notification.Name("playerStatusChanged"),
            object: nil,
            userInfo: nil
        )
    }
    
}



extension TimeInterval {
    // TimeInterval format to 00:00
    func toString() -> String {
        let min = Int(self/60)
        let sec = Int(self.truncatingRemainder(dividingBy: 60))
        return String(format: "%02d:%02d", min, sec)
    }
    
    // TimeInterval format to 00:00.00
    func toStringContainMilisec() -> String {
        let min = Int(self/60)
        let sec = Int(self.truncatingRemainder(dividingBy: 60))
        let mili = (Int((self*100).truncatingRemainder(dividingBy: 100)))
        return String(format: "%02d:%02d.%02d", min, sec, mili)
    }
}
