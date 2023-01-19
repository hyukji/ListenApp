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
    var player : AVAudioPlayer!
    var audio : NowAudio?
    var status : PlayerStatus = .pause
    
    var timeInterval = 5.0
    var isNewAudio = false
    
    
    
    func configurePlayer() {
        if !isNewAudio { return }
        if status == .play { stopPlayer() }
        
        let url = getDocumentFileURL()
        do {
            isNewAudio = false
            player = try AVAudioPlayer(contentsOf: url)
            playPlayer()
        } catch {
            print("Error: Audio File missing.")
        }
    }
    
    func getDocumentFileURL() -> URL {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        let title = audio?.title ?? ""
        let finalURL = documentsURL.appendingPathComponent("\(title).mp3")
        
        return finalURL
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
