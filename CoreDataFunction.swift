//
//  CoreDataFunction.swift
//  ListenApp
//
//  Created by 곽지혁 on 2023/01/19.
//

import UIKit
import CoreData
import DSWaveformImage


class CoreDataFunc {
    static let shared = CoreDataFunc()
    
    var appDelegate : AppDelegate!
    var context : NSManagedObjectContext!
    var audioList : [AudioData] = []
    
    private init() {
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        context = appDelegate.persistentContainer.viewContext
        
        audioList = fetchAudio()
    }
    
    func initializeAnalysisSave(item : DocumentItem) {
        guard let waveformAnalyzer = WaveformAnalyzer(audioAssetURL: item.url) else {return}
        let duration = 1 * 60
        let width = duration * 10
        let count = Int(width * 3 / 2)
        waveformAnalyzer.samples(count: count) { samples in
            let audio = AudioData(title: item.title,
                                  location : item.location,
                                  audioExtension: item.audioExtension ?? "",
                                  waveAnalysis: samples ?? [0.0000],
                                  currentTime: 0.0,
                                  duration: 0.0,
                                  creationDate: item.creationDate)
            
            self.saveAudio(audioData: audio)
        }
    }
    
    func saveAudio(audioData : AudioData) {
        let entity = NSEntityDescription.entity(forEntityName: "Audio", in: self.context)
        if let entity = entity {
            let audio = NSManagedObject(entity: entity, insertInto: context)

            audio.setValue(audioData.title, forKey: "title")
            audio.setValue(audioData.location, forKey: "location")
            audio.setValue(audioData.audioExtension, forKey: "audioExtension")
            audio.setValue(audioData.waveAnalysis, forKey: "waveAnalysis")
            audio.setValue(audioData.currentTime, forKey: "currentTime")
            audio.setValue(audioData.duration, forKey: "duration")
            audio.setValue(audioData.creationDate, forKey: "creationDate")

            do {
                try context.save()
                print("saved! \(audioData.title)")
                audioList = fetchAudio()
            } catch {
                print(error.localizedDescription)
            }
        }
    }


    // 저장된 audio 데이터 가져와 AudioData instance list
    func fetchAudio() -> [AudioData] {
        var fetchedList : [AudioData] = []
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Audio")
        do {
            let resultList = try context.fetch(fetchRequest)
            for data in resultList {
                
                let title = data.value(forKey: "title") as! String
                let location = data.value(forKey: "location") as! String
                let audioExtension = data.value(forKey: "audioExtension") as! String
                let waveAnalysis = data.value(forKey: "waveAnalysis") as? [Float] ?? []
                let currentTime = data.value(forKey: "currentTime") as! Double
                let duration = data.value(forKey: "duration") as! Double
                let creationDate = data.value(forKey: "creationDate") as! Date
                
                fetchedList.append(
                    AudioData(
                              title: title,
                              location: location,
                              audioExtension: audioExtension,
                              waveAnalysis: waveAnalysis,
                              currentTime: currentTime,
                              duration: duration,
                              creationDate: creationDate)
                )
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        print("fetch CoreData")
        fetchedList.forEach {
            print($0.title, $0.location)
        }
        return fetchedList
    }

    
    
    // title이 같은 데이터 찾아서 해당 데이터 업데이트
    func updateTitleOfSelectedDocumentItem(newtitle: String, item : DocumentItem) {
        print("newTitie", newtitle)
        print("should change Item : \(item.title), \(item.location)")
        if item.type == .folder {
            var newFolderLocationComponents = item.location.components(separatedBy: "/")
            newFolderLocationComponents[newFolderLocationComponents.count-1] = newtitle
            let newFolderLocation = newFolderLocationComponents.joined(separator: "/")
            print("newFolderLocation",newFolderLocation)
            
            let fileList = MyFileManager().getAllAudioFileListFromFolder(folderItem: item)
            for fileItem in fileList {
                var newFileLocationComponents = fileItem.location.components(separatedBy: item.title)
                newFileLocationComponents[0] = "\(newFolderLocation)"
                let newFileLocation = newFileLocationComponents.joined(separator: "")
                
                print("change location \(fileItem.location) to \(newFileLocation)")
            
                print("fileItem", fileItem.title, fileItem.location)
                    
                
                let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Audio")
                fetchRequest.predicate = NSPredicate(
                    format: "title == %@ && location == %@", fileItem.title, fileItem.location
                )
                do {
                    let result = try context.fetch(fetchRequest)
                    if result.count > 0 {
                        print("file rename0")
                        let audio = result[0]
                        audio.setValue(newFileLocation, forKey: "location")}
                    else {
                    print("************** 폴더 이름 변환 -> 파일 위치 변환 실패******************")
                    }
                } catch {
                    print(error)
                }
            }
        }
        else if item.type == .file {
            print(item.title, item.location)
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Audio")
            fetchRequest.predicate = NSPredicate(
                format: "title == %@ && location == %@", item.title, item.location
            )
            do {
                let result = try context.fetch(fetchRequest)
                if result.count > 0 {
                    let audio = result[0]
                    audio.setValue(newtitle, forKey: "title")
                } else {
                    print("************** 파일 이름 변환 실패******************")
                }
                
            } catch {
                print(error)
            }
        }
        
        do {
            try context.save()
            audioList = fetchAudio()
        } catch {
            print(error)
        }
        
    }
    
    
    func updateLocationOfSelectedItem(location: String, selectedPlayList : [DocumentItem]) {
        for shouldUpdateItem in selectedPlayList {
            if shouldUpdateItem.type == .file {
                let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Audio")
                fetchRequest.predicate = NSPredicate(
                    format: "title == %@ && location == %@", shouldUpdateItem.title, shouldUpdateItem.location
                )
                do {
                    let result = try context.fetch(fetchRequest)
                    let audio = result[0]
                    audio.setValue(location, forKey: "location")
                } catch {
                    print(error)
                }
            }
            else {
                let fileList = MyFileManager().getAllAudioFileListFromFolder(folderItem: shouldUpdateItem)
                for fileItem in fileList {
                    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Audio")
                    fetchRequest.predicate = NSPredicate(
                        format: "title == %@ && location == %@", fileItem.title, fileItem.location
                    )
                        
                    var newFileLocationComponents = fileItem.location.components(separatedBy: shouldUpdateItem.title)
                    newFileLocationComponents[0] = "\(location)/"
                    let newFileLocation = newFileLocationComponents.joined(separator: shouldUpdateItem.title)
                    
                    print("change location \(fileItem.location) to \(newFileLocation)")
                    do {
                        let result = try context.fetch(fetchRequest)
                        let audio = result[0]
                        audio.setValue(newFileLocation, forKey: "location")
                    } catch {
                        print(error)
                    }
                }
            }
        }
        
        do {
            try context.save()
            print("updateLocationOfSelectedItem")
            audioList = fetchAudio()
        } catch {
            print(error)
        }
    }


    
    // 특정 [documentItem]을 CoreData에서 삭제
    func deleteSelectedPlayList(selectedPlayList : [DocumentItem]) {
        selectedPlayList.forEach{
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Audio")
            fetchRequest.predicate = NSPredicate(
                format: "title == %@ && location == %@", $0.title, $0.location
            )

            do {
                let result = try context.fetch(fetchRequest)
                for obj in result {
                    context.delete(obj)
                }
            } catch {
                print(error)
            }
        }
        
        do {
            try context.save()
            print("delete")
            audioList = fetchAudio()
        } catch {
            print(error)
        }
    }
    
    // 특정 audio들 CoreData에서 삭제
    func deleteSelectedAudioList(selectedAudioList : [AudioData]) {
        selectedAudioList.forEach{
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Audio")
            fetchRequest.predicate = NSPredicate(
                format: "title == %@ && location == %@", $0.title, $0.location
            )

            do {
                let result = try context.fetch(fetchRequest)
                for obj in result {
                    context.delete(obj)
                }
            } catch {
                print(error)
            }
        }
        
        do {
            try context.save()
            print("delete")
            audioList = fetchAudio()
        } catch {
            print(error)
        }
    }
    
    func resetAllRecords() // entity = Your_Entity_Name
        {
            let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Audio")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
            do
            {
                try context.execute(deleteRequest)
                try context.save()
                print("deleteall")
            }
            catch
            {
                print ("There was an error")
            }
        }
    
    
    
    
    
}


// CoreAudio 와 document 동기화 관련 functions
extension CoreDataFunc {
    // 전체 playList와 coreAduio 동기화
    func synchronizeAudioListAndPlayList() {
        let playList = MyFileManager().getAllAudioFileListFromDocument()
        print("fetch playlist")
        playList.forEach{
            print($0.title, $0.location)
        }
        delAudioDataIsnotInPlayList(playList: playList)
        saveAudioDataIsnotInAudioList(playList: playList)
    }
    
    // 특정 location의 playList와 coreAduio 동기화
//    func synchronizeAudioListAndTargetPlayList(location : String, playList : [DocumentItem]) {
//        delAudioDataIsnotInTargetPlayList(location : location, playList : playList)
//        saveAudioDataIsnotInAudioList(playList: playList)
//    }
    
    // playlist에는 없는데 coreAduio에만 있는 데이터 삭제
    private func delAudioDataIsnotInPlayList(playList : [DocumentItem]) {
        var shouldDeleteAudioList : [AudioData] = []
        audioList.forEach { audio in
            if !playList.contains(where: {
                $0.type == .file &&
                $0.title == audio.title &&
                $0.location == audio.location &&
                $0.audioExtension == audio.audioExtension &&
                $0.creationDate == audio.creationDate
            }) {
                shouldDeleteAudioList.append(audio)
            }
        }
        
        if shouldDeleteAudioList.count > 0 {
            print("shouldDeleteAudioList")
            shouldDeleteAudioList.forEach{
                print($0.title, $0.location)
            }
            deleteSelectedAudioList(selectedAudioList: shouldDeleteAudioList)
        }
    }
    
    
    // 해당 playlist에는 없는데 coreAduio에만 있는 데이터 삭제
//    private func delAudioDataIsnotInTargetPlayList(location : String, playList : [DocumentItem]) {
//        var shouldDeleteAudioList : [AudioData] = []
//        audioList.forEach { audio in
//            if audio.location == location {
//                if !playList.contains(where: {
//                    $0.type == .file &&
//                    $0.title == audio.title &&
//                    $0.audioExtension == audio.audioExtension &&
//                    $0.creationDate == audio.creationDate
//                }) {
//                    shouldDeleteAudioList.append(audio)
//                }
//            }
//        }
//        if shouldDeleteAudioList.count > 0 { deleteSelectedAudioList(selectedAudioList: shouldDeleteAudioList) }
//    }
    
    // coreAduio 에는 없고 해당 playlist에만 있는 데이터를 coreAduio에 저장
    private func saveAudioDataIsnotInAudioList(playList : [DocumentItem]) {
        playList.forEach { item in
            if item.type == .file && !audioList.contains(where: { item.location == $0.location && item.title == $0.title }) {
                print("should save \(item.title)")
                initializeAnalysisSave(item: item)
            }
        }
    }
    
}

