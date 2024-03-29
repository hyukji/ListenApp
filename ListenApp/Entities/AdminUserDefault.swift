//
//  AdminUserDefault.swift
//  ListenApp
//
//  Created by 곽지혁 on 2023/02/24.
//

import UIKit


class AdminUserDefault {
    static let shared = AdminUserDefault()
    
    let settingData: [String: [String]] = [
//        "thema" : ["시스템 설정 모드", "라이트 모드", "다크 모드"],
//        "language" : ["한국어", "영어"],
        "thema" : ["라이트 모드"],
        "language" : ["한국어"],
        "startLocation" : ["처음부터", "종료된 시점부터"],
        "secondTerm" : ["1s", "2s", "3s", "5s", "10s", "15s"],
        "repeatTerm" : ["0s", "0.5s", "1s", "2s", "3s", "5s", "10s", "15s"]
    ]
    
    var settingSelected : [String: Int] = [
        "thema" : 0,
        "language" : 0,
        "startLocation" : 0,
        "secondTerm" : 0,
        "repeatTerm" : 1
    ]
    
    let themas = [UIUserInterfaceStyle.unspecified, UIUserInterfaceStyle.light, UIUserInterfaceStyle.dark]
    var rateSetting : Float = 1.0
    
    var LastFileSystemFileNumber : Int = 0
    var LastAudioCreationDate : Date = Date()
    
    private init() {
        registerData()
        loadData()
    }
    
    func registerData() {
        UserDefaults.standard.register(
          defaults: [
            "thema" : settingSelected["thema"]!,
            "language" : settingSelected["language"]!,
             
            "startLocation" : settingSelected["startLocation"]!,
            "secondTerm" : settingSelected["secondTerm"]!,
            "repeatTerm" : settingSelected["repeatTerm"]!,
                        
            "rateSetting" : rateSetting,
            
            "LastFileSystemFileNumber" : LastFileSystemFileNumber,
            "LastAudioCreationDate" : LastAudioCreationDate
          ])
    }
    
    
    func loadData() {
        settingSelected["thema"] = UserDefaults.standard.integer(forKey: "thema")
        settingSelected["langauge"] = UserDefaults.standard.integer(forKey: "langauge")
        
        settingSelected["startLocation"] = UserDefaults.standard.integer(forKey: "startLocation")
        settingSelected["secondTerm"] = UserDefaults.standard.integer(forKey: "secondTerm")
        settingSelected["repeatTerm"] = UserDefaults.standard.integer(forKey: "repeatTerm")
        
        rateSetting = UserDefaults.standard.float(forKey: "rateSetting")
        
        LastFileSystemFileNumber = UserDefaults.standard.integer(forKey: "LastFileSystemFileNumber")
        LastAudioCreationDate = UserDefaults.standard.value(forKey: "LastAudioCreationDate") as! Date
    }
    
    func getThema() -> UIUserInterfaceStyle {
        return themas[settingSelected["thema"] ?? 0]
    }
    
    // 마지막으로 재생한 오디오 저장
    func updateLastAudio(audio : AudioData) {
        LastFileSystemFileNumber = audio.fileSystemFileNumber
        LastAudioCreationDate = audio.creationDate
        
        UserDefaults.standard.set(LastFileSystemFileNumber, forKey: "LastFileSystemFileNumber")
        UserDefaults.standard.set(LastAudioCreationDate, forKey: "LastAudioCreationDate")
    }
    
    func saveRateSettingData(new : Float) {
        rateSetting = new
        UserDefaults.standard.set(new, forKey: "rateSetting")
    }
    
    // setting 관련 데이터 저장
    func saveListSettingData(name : String, new : Int) {
        settingSelected[name] = new
        UserDefaults.standard.set(new, forKey: name)
    }
    
    
}
