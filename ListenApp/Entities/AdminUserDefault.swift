//
//  AdminUserDefault.swift
//  ListenApp
//
//  Created by 곽지혁 on 2023/02/24.
//

import UIKit

class AdminUserDefault {
    
    static var thema : Int = 0
    static var langauge : Int = 0
    
    static var startLocation : Int = 0
    static var audioSpeed : Double = 1.0
    static var secondTerm : Int = 2
    
    
    static func configuration() {
        registerData()
        loadData()
    }
    
    static func registerData() {
        UserDefaults.standard.register(
          defaults: [
            "thema" : AdminUserDefault.thema,
            "langauge" : AdminUserDefault.langauge,
             
            "startLocation" : AdminUserDefault.startLocation,
            "audioSpeed" : AdminUserDefault.audioSpeed,
            "secondTerm" : AdminUserDefault.secondTerm
          ])
    }
    
    
    static func loadData() {
        AdminUserDefault.thema = UserDefaults.standard.integer(forKey: "thema")
        AdminUserDefault.langauge = UserDefaults.standard.integer(forKey: "langauge")
        
        AdminUserDefault.startLocation = UserDefaults.standard.integer(forKey: "startLocation")
        AdminUserDefault.audioSpeed = UserDefaults.standard.double(forKey: "audioSpeed")
        AdminUserDefault.secondTerm = UserDefaults.standard.integer(forKey: "secondTerm")
    }
    
    
    func saveData(name : String, new : Any) {
        UserDefaults.standard.set(new, forKey: name)
    }
    
    func saveLangauge(new : Int) {
        UserDefaults.standard.set(new, forKey: "langauge")
        AdminUserDefault.langauge = new
    }
    
    func saveStartLocation(new : Int) {
        UserDefaults.standard.set(new, forKey: "startLocation")
        AdminUserDefault.startLocation = new
    }
    
    func saveAudioSpeed(new : Double) {
        UserDefaults.standard.set(new, forKey: "audioSpeed")
        AdminUserDefault.audioSpeed = new
    }
    
    func saveSecondTerm(new : Int) {
        UserDefaults.standard.set(new, forKey: "secondTerm")
        AdminUserDefault.secondTerm = new
    }
    
}
