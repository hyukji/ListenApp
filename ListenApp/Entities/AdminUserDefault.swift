//
//  AdminUserDefault.swift
//  ListenApp
//
//  Created by 곽지혁 on 2023/02/24.
//

import UIKit


class AdminUserDefault {
    
    static let settingData: [String: [String]] = [
        "thema" : ["라이트 모드", "다크 모드"],
        "language" : ["한국어", "영어"],
        "startLocation" : ["처음부터", "종료된 시점부터"],
        "audioSpeed" : {
            var arr : [String] = []
            for i in 5...20 { arr.append(String(Double(i) / 10.0)) }

            return arr
        }(),
        "secondTerm" : ["1s", "2s", "3s", "5s", "10s", "15s"]
    ]
    
    static var settingSelected : [String: Int] = [
        "thema" : 0,
        "language" : 0,
        "startLocation" : 0,
        "audioSpeed" : 0,
        "secondTerm" : 0
    ]
    
    static func configuration() {
        registerData()
        loadData()
    }
    
    static func registerData() {
        UserDefaults.standard.register(
          defaults: [
            "thema" : AdminUserDefault.settingSelected["thema"]!,
            "language" : AdminUserDefault.settingSelected["language"]!,
             
            "startLocation" : AdminUserDefault.settingSelected["startLocation"]!,
            "audioSpeed" : AdminUserDefault.settingSelected["audioSpeed"]!,
            "secondTerm" : AdminUserDefault.settingSelected["secondTerm"]!,
          ])
    }
    
    
    static func loadData() {
        AdminUserDefault.settingSelected["thema"] = UserDefaults.standard.integer(forKey: "thema")
        AdminUserDefault.settingSelected["langauge"] = UserDefaults.standard.integer(forKey: "langauge")
        
        AdminUserDefault.settingSelected["startLocation"] = UserDefaults.standard.integer(forKey: "startLocation")
        AdminUserDefault.settingSelected["audioSpeed"] = UserDefaults.standard.integer(forKey: "audioSpeed")
        AdminUserDefault.settingSelected["secondTerm"] = UserDefaults.standard.integer(forKey: "secondTerm")
    }
    
    
    func saveData(name : String, new : Int) {
        AdminUserDefault.settingSelected[name] = new
        UserDefaults.standard.set(new, forKey: name)
    }
    
    
}
