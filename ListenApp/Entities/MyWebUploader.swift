//
//  MyWebUploader.swift
//  ListenApp
//
//  Created by 곽지혁 on 2023/01/20.
//

import GCDWebServer

class MyWebUploader {
    // move webuploader to outside of init func to fix app crash issue.
    let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    lazy var webUploader = GCDWebUploader(uploadDirectory: self.documentsPath)
    
    func initWebUploader() -> String {
        var ipAddress = String()
        
        webUploader.start()
        webUploader.allowedFileExtensions = ["mp3", "aac", "m4a", "wav"]
        if webUploader.serverURL != nil {
            // retrieve IP address from URL
            let str = webUploader.serverURL!.absoluteString
            let start = str.index(str.startIndex, offsetBy: 7)
            let end = str.index(str.endIndex, offsetBy: -1)
            let range = start..<end
            let mySubstring = str[range]
            ipAddress = String(mySubstring)
        } else {
            ipAddress = "No Wifi connected"
        }
        
        return ipAddress
    }
    
    func stopWebUploader() {
        webUploader.stop()
    }
}

