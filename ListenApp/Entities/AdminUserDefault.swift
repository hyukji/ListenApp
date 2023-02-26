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
        "thema" : ["기본 모드", "라이트 모드", "다크 모드"],
        "language" : ["한국어", "영어"],
        "startLocation" : ["처음부터", "종료된 시점부터"],
        "audioSpeed" : {
            var arr : [String] = []
            for i in 5...20 { arr.append(String(Double(i) / 10.0)) }

            return arr
        }(),
        "secondTerm" : ["1s", "2s", "3s", "5s", "10s", "15s"]
    ]
    
    var settingSelected : [String: Int] = [
        "thema" : 0,
        "language" : 0,
        "startLocation" : 0,
        "audioSpeed" : 0,
        "secondTerm" : 0
    ]
    
    let themas = [UIUserInterfaceStyle.unspecified, UIUserInterfaceStyle.light, UIUserInterfaceStyle.dark]
    var LastFileSystemFileNumber : Int = 0
    var LastAudioCreationDate : Date = Date()
    
    private init() {
        registerData()
        loadData()
        print("init")
    }
    
    func registerData() {
        UserDefaults.standard.register(
          defaults: [
            "thema" : settingSelected["thema"]!,
            "language" : settingSelected["language"]!,
             
            "startLocation" : settingSelected["startLocation"]!,
            "audioSpeed" : settingSelected["audioSpeed"]!,
            "secondTerm" : settingSelected["secondTerm"]!,
            
            "LastFileSystemFileNumber" : LastFileSystemFileNumber,
            "LastAudioCreationDate" : LastAudioCreationDate
          ])
    }
    
    
    func loadData() {
        settingSelected["thema"] = UserDefaults.standard.integer(forKey: "thema")
        settingSelected["langauge"] = UserDefaults.standard.integer(forKey: "langauge")
        
        settingSelected["startLocation"] = UserDefaults.standard.integer(forKey: "startLocation")
        settingSelected["audioSpeed"] = UserDefaults.standard.integer(forKey: "audioSpeed")
        settingSelected["secondTerm"] = UserDefaults.standard.integer(forKey: "secondTerm")
        
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
    
    // setting 관련 데이터 저장
    func saveSettingData(name : String, new : Int) {
        settingSelected[name] = new
        UserDefaults.standard.set(new, forKey: name)
    }
    
    
}
