//
//  FileManager.swift
//  ListenApp
//
//  Created by 곽지혁 on 2023/01/21.
//

import Foundation

class MyFileManager {
    let fileManager = FileManager.default
    let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    func createForderInDocument(title : String, documentsURL : URL) {
        let directoryURL = documentsURL.appendingPathComponent(title)
        
        do {
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: false)
        } catch let e as NSError {
            print(e.localizedDescription)
        }
    }
    
    
    func deleteFilesInDocument(items : [DocumentItem]) {
        items.forEach{
            do {
                try fileManager.removeItem(at: $0.url)
            } catch let e {
                print(e.localizedDescription)
            }
        }
    }
    
    func renameFileInDocument(item : DocumentItem, newTitle : String, url : URL) {
        let originPath = item.url.path
        let newPath = item.url.pathExtension == "" ? url.path + "/\(newTitle)"  : url.path + "/\(newTitle).\(item.url.pathExtension)"
        
        do {
            try fileManager.moveItem(atPath: originPath, toPath: newPath)
        } catch let e as NSError {
            print(e.localizedDescription)
        }
    }
    
    func moveFileInDocument(selectedURLs : [URL], newUrl : URL) {
        var URLs = selectedURLs
        URLs.removeFirst()
        
        URLs.forEach{
            let originPath = $0.path
            let newPath = newUrl.path + "/\($0.lastPathComponent)"
            
            do {
                try fileManager.moveItem(atPath: originPath, toPath: newPath)
            } catch let e as NSError {
                print(e.localizedDescription)
            }
        }
    }
    
        
    
    func getAudioFileListFromDocument(location : String) -> [DocumentItem] {
        let allowedFileExtensions = ["mp3", "aac", "m4a", "wav"]
        let directoryURL = documentURL.appending(path: location, directoryHint: .isDirectory)
        
        var list : [DocumentItem] = []
        var urls : [URL] = []
        do {
            urls = try fileManager.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil)
            
            for url in urls {
                if url.deletingPathExtension().lastPathComponent == ".Trash" { continue }
                
                let attr = try fileManager.attributesOfItem(atPath: url.path) as NSDictionary
                if url.hasDirectoryPath {
                    let item = DocumentItem(title: url.deletingPathExtension().lastPathComponent,
                                            location : "\(location)/\(url.deletingPathExtension().lastPathComponent)",
                                            url: url,
                                            creationDate : attr.fileCreationDate() ?? Date(),
                                            size : attr.fileSize(),
                                            audioExtension: nil,
                                            type: .folder)
                    list.append(item)
                }
                else if allowedFileExtensions.contains(url.pathExtension) {
                    let item = DocumentItem(title: url.deletingPathExtension().lastPathComponent,
                                            location : location,
                                            url: url,
                                            creationDate : attr.fileCreationDate() ?? Date(),
                                            size : attr.fileSize(),
                                            audioExtension: url.pathExtension,
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
    
    // document에 존재하는 모든 파일 가져오기
    func getAllAudioFileListFromDocument() -> [DocumentItem] {
        let allowedFileExtensions = ["mp3", "aac", "m4a", "wav"]
        
        var Filelist : [DocumentItem] = []
        var FolderList : [DocumentItem] =
        [
            DocumentItem(
                title: "Documents",
                location: "",
                url: documentURL,
                creationDate: Date(),
                size: 0,
                audioExtension: nil,
                type: .folder)
        ]
        
        do {
            while FolderList.count > 0 {
                guard let item = FolderList.popLast() else { return Filelist }
                let urls = try fileManager.contentsOfDirectory(at: item.url, includingPropertiesForKeys: nil)
                for url in urls {
                    if url.deletingPathExtension().lastPathComponent == ".Trash" { continue }
                    let attr = try fileManager.attributesOfItem(atPath: url.path) as NSDictionary
                    if url.hasDirectoryPath {
                        let folderItem = DocumentItem(title: url.deletingPathExtension().lastPathComponent,
                                                location : "\(item.location)/\(url.deletingPathExtension().lastPathComponent)",
                                                      url: url,
                                                creationDate : attr.fileCreationDate() ?? Date(),
                                                size : attr.fileSize(),
                                                audioExtension: nil,
                                                type: .folder)
                        FolderList.append(folderItem)
                    }
                    else if allowedFileExtensions.contains(url.pathExtension) {
                        let fileItem = DocumentItem(title: url.deletingPathExtension().lastPathComponent,
                                                    location : item.location,
                                                    url: url,
                                                    creationDate : attr.fileCreationDate() ?? Date(),
                                                    size : attr.fileSize(),
                                                    audioExtension: url.pathExtension,
                                                    type: .file)
                        Filelist.append(fileItem)
                    }
                }
            }
        }
        catch {
            print("[Error] : \(error.localizedDescription)")
        }
        
        return Filelist
    }
    
    
    
    
    
//
    
    
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
