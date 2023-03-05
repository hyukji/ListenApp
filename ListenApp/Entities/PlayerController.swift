//
//  PlayerClass.swift
//  ListenApp
//
//  Created by 곽지혁 on 2023/01/16.
//

protocol AdminPlayBtnProtocol {
    func setPlayButtonImage()
}

import Foundation
import AVFoundation

enum PlayerStatus {
    case play
    case pause
    case stop
    case intermit
    case autoIntermit
    case ABrepeatIntermit
    case WaveRepeatIntermit
}

class PlayerController {
    static let playerController = PlayerController()
    
    var player : AVAudioPlayer!
    var audio : AudioData?
    var url : URL?
    
    var playButtonDelegate : AdminPlayBtnProtocol?
    
    var status : PlayerStatus = .pause
    
    var isNewAudio = false
    
    let changedAmountPerSec = 100.0
    var repeatTerm = 1.0
    
    // ab반복
    var shouldABRepeat = false
    var positionA : Int?
    var positionB : Int?
    
    // wave반복
    var shouldSectionRepeat = false
    var positionSectionStart : Int?
    var positionSectionEnd : Int?
    
    private init() { }
    
    func configurePlayer(url : URL, audio : AudioData) {
        if !isNewAudio { return }
        if status == .play { stopPlayer() }
        
        do {
            isNewAudio = false
            
            shouldABRepeat = false
            positionA = nil
            positionB = nil
            
            shouldSectionRepeat = false
            positionSectionStart = nil
            positionSectionEnd = nil
            
            self.audio = audio
            self.url = url
            
            player = try AVAudioPlayer(contentsOf: url)
            
            // 오디오 배속 설정
            player.enableRate = true
            player.rate = AdminUserDefault.shared.rateSetting
            
            // 시작위치 설정
            let startLocationSelected = AdminUserDefault.shared.settingSelected["startLocation"] ?? 0
            player.currentTime = (startLocationSelected == 0) ? 0.0 : self.audio!.currentTime
            
            // LastAudio 설정
            AdminUserDefault.shared.updateLastAudio(audio: audio)
            
        } catch {
            print("Error: Audio File missing.")
        }
    }
    
    func playPlayer() {
//        try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
//        try AVAudioSession.sharedInstance().setActive(true)
//        player.prepareToPlay()
        player.play()
        status = .play

        NotificateTo()
        playButtonDelegate?.setPlayButtonImage()
    }
    
    func stopPlayer() {
        player.stop()
        player.currentTime = 0
        status = .stop
        
        NotificateTo()
        playButtonDelegate?.setPlayButtonImage()
    }
    
    func pausePlayer() {
        player.pause()
        status = .pause
        
        NotificateTo()
        playButtonDelegate?.setPlayButtonImage()
    }
    
    func intermitPlayer() {
        player.pause()
        status = .intermit
        
        NotificateTo()
        playButtonDelegate?.setPlayButtonImage()
    }
    
    func autoIntermittPlayer(intermitCategory : PlayerStatus) {
        player.pause()
        status = intermitCategory
        
        print("autoIntermittPlayer", status)
        playButtonDelegate?.setPlayButtonImage()
        print("after setPlaybtn")
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
    
    func rePlayPlayer() {
        stopPlayer()
        playPlayer()
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
