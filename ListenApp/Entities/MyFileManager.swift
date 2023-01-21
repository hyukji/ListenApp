//
//  FileManager.swift
//  ListenApp
//
//  Created by 곽지혁 on 2023/01/21.
//

import Foundation

class MyFileManager {
    let fileManager = FileManager.default
    
    func createForderInDocument(title : String, documentsURL : URL) {
        let directoryURL = documentsURL.appendingPathComponent(title)
        
        do {
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: false)
        } catch let e as NSError {
            print(e.localizedDescription)
        }
    }
    
    
    func deleteFileInDocument(extendTitle : String, documentsURL : URL) {
        let fileURL = documentsURL.appendingPathComponent(extendTitle)

        do {
            try fileManager.removeItem(at: fileURL)
        } catch let e {
            print(e.localizedDescription)
        }
    }
    
    func getAudioFileListFromDocument(url : URL) -> [DocumentItem] {
        let allowedFileExtensions = ["mp3", "aac", "m4a", "wav"]
                
        // [애플리케이션 폴더에 저장되어 있는 파일 리스트 확인]
        var list : [DocumentItem] = []
        var urls : [URL] = []
        do {
            urls = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
            
            for url in urls {
                if url.deletingPathExtension().lastPathComponent == ".Trash" { continue }
                
                if url.hasDirectoryPath {
                    let item = DocumentItem(title: url.deletingPathExtension().lastPathComponent,
                                            url: url,
                                            type: .folder)
                    list.append(item)
                }
                else if allowedFileExtensions.contains(url.pathExtension) {
                    let item = DocumentItem(title: url.deletingPathExtension().lastPathComponent,
                                            url: url,
                                            type: .file)
                    list.append(item)
                }
            }
        }
        catch {
            print("[Error] : \(error.localizedDescription)")
        }
        
        return list
        
    }
    
//    func getFileInDocument() {
//        let fileManager = FileManager.default
//        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
//
//        let finalURL = documentsURL.appendingPathComponent("FileName")
//
//        do {
//            let text = try String(contentsOf: finalURL, encoding: .utf8)
//            print(text)
//        } catch let e {
//            print(e.localizedDescription)
//        }
//    }
//
    
    
//    func createFileInDocument() {
//        let documentURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
//        let fileName = documentURL.appendingPathComponent("FileName.txt")
//
//        let text = "Hello World!"
//        do {
//            try text.write(to: fileName, atomically: false, encoding: .utf8)
//        } catch let e as NSError {
//            print(e.localizedDescription)
//        }
//    }
}