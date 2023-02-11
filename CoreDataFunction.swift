//
//  CoreDataFunction.swift
//  ListenApp
//
//  Created by 곽지혁 on 2023/01/19.
//

import UIKit
import CoreData
import DSWaveformImage
import AVFoundation


class CoreDataFunc {
    static let shared = CoreDataFunc()
    static var shouldUpdateCount = 0
    
    var appDelegate : AppDelegate!
    var context : NSManagedObjectContext!
    var audioList : [AudioData] = []
    
    private init() {
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        context = appDelegate.persistentContainer.viewContext
        
        audioList = fetchAudio()
    }
    
    
    func saveAudio(audioData : AudioData) {
        let entity = NSEntityDescription.entity(forEntityName: "Audio", in: self.context)
        if let entity = entity {
            let audio = NSManagedObject(entity: entity, insertInto: context)

            audio.setValue(audioData.fileSystemFileNumber, forKey: "fileSystemFileNumber")
            audio.setValue(audioData.creationDate, forKey: "creationDate")
            audio.setValue(audioData.currentTime, forKey: "currentTime")
            audio.setValue(audioData.waveAnalysis, forKey: "waveAnalysis")
            audio.setValue(audioData.duration, forKey: "duration")

            do {
                try context.save()
                print("saved! \(audioData.fileSystemFileNumber)")
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
                
                let fileSystemFileNumber = data.value(forKey: "fileSystemFileNumber") as! Int
                let waveAnalysis = data.value(forKey: "waveAnalysis") as? [Float] ?? []
                let currentTime = data.value(forKey: "currentTime") as! Double
                let duration = data.value(forKey: "duration") as! Double
                let creationDate = data.value(forKey: "creationDate") as! Date
                
                fetchedList.append(
                    AudioData(
                        fileSystemFileNumber : fileSystemFileNumber,
                        creationDate: creationDate,
                        currentTime: currentTime,
                        waveAnalysis: waveAnalysis,
                        duration: duration
                    )
                )
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        print("fetch CoreData")
        fetchedList.forEach {
            print("\($0.fileSystemFileNumber) waveAnalysis.count = \($0.waveAnalysis.count)")
        }
        return fetchedList
    }
    
    
    
    
   // 특정 audioList를 CoreData에서 삭제
    func deleteSelectedAudioList(selectedAudioList : [AudioData]) {
        selectedAudioList.forEach{
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Audio")
            fetchRequest.predicate = NSPredicate(
                format: "fileSystemFileNumber == %d && creationDate == %@", $0.fileSystemFileNumber, $0.creationDate as NSDate
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
    func synchronizeAudioListAndPlayList(checkUpdateHandler : @escaping () -> Void) {
        let playList = MyFileManager().getAllAudioFileListFromDocument()
        self.delAudioDataIsnotInPlayList(playList: playList)
        let shouldSaveList = self.saveAudioDataIsnotInAudioList(playList: playList)
        
        CoreDataFunc.shouldUpdateCount = shouldSaveList.count
        checkUpdateHandler()
        
        self.getAndupdateWaveAnalysis(itemList: shouldSaveList, checkUpdateHandler: checkUpdateHandler)
    }
    
    // playlist에는 없는데 coreAduio에만 있는 데이터 삭제
    private func delAudioDataIsnotInPlayList(playList : [DocumentItem]) {
        var shouldDeleteAudioList : [AudioData] = []
        audioList.forEach { audio in
            if !playList.contains(where: {
                $0.type == .file &&
                $0.fileSystemFileNumber == audio.fileSystemFileNumber &&
                $0.creationDate == audio.creationDate
            }) {
                shouldDeleteAudioList.append(audio)
            }
        }
        
        if shouldDeleteAudioList.count > 0 {
            shouldDeleteAudioList.forEach{
                let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Audio")
                fetchRequest.predicate = NSPredicate(
                    format: "fileSystemFileNumber == %d && creationDate == %@", $0.fileSystemFileNumber, $0.creationDate as NSDate
                )
                
                do {
                    let result = try context.fetch(fetchRequest)
                    for obj in result {
                        context.delete(obj)
                        print("delete \($0.fileSystemFileNumber)")
                    }
                } catch {
                    print(error)
                }
            }
            
            do {
                try context.save()
                //            audioList = fetchAudio()
            } catch {
                print(error)
            }
        }
        
    }

    // coreAduio 에는 없고 해당 playlist에만 있는 데이터를 coreAduio에 저장
    private func saveAudioDataIsnotInAudioList(playList : [DocumentItem]) -> [DocumentItem] {
        var shouldSaveList : [DocumentItem] = []
        playList.forEach { item in
            if item.type == .file
                && !audioList.contains(where: {
                    item.fileSystemFileNumber == $0.fileSystemFileNumber
                    && item.creationDate == $0.creationDate })
            {
                print("should save \(item.title)")
                shouldSaveList.append(item)
            }
        }
        
        shouldSaveList.forEach{ item in
            do {
                let player = try AVAudioPlayer(contentsOf: item.url)
                let audio = AudioData(
                    fileSystemFileNumber: item.fileSystemFileNumber,
                    creationDate : item.creationDate,
                    currentTime: 0.0,
                    waveAnalysis: [0.0],
                    duration: player.duration
                )
                
                self.saveAudio(audioData: audio)
                
            } catch {
                print("save 실패")
            }
        }
        
        return shouldSaveList
    }
    
    
    func getAndupdateWaveAnalysis(itemList : [DocumentItem], checkUpdateHandler : @escaping () -> Void) {
        itemList.forEach { item in
            guard let waveformAnalyzer = WaveformAnalyzer(audioAssetURL: item.url) else {return}
            
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Audio")
            fetchRequest.predicate = NSPredicate(
                format: "fileSystemFileNumber == %d && creationDate == %@", item.fileSystemFileNumber, item.creationDate as NSDate
            )
            do {
                let result = try self.context.fetch(fetchRequest)
                if result.count > 0 {
                    let audio = result[0]
                    let duration = audio.value(forKey: "duration") as! Double
                    let count = Int(duration * 100)
                    waveformAnalyzer.samples(count: count) { samples in
                        let waveAnalysis = samples ?? [0.0]
                        audio.setValue(waveAnalysis, forKey: "waveAnalysis")
                        print("update", item.fileSystemFileNumber)
                        CoreDataFunc.shouldUpdateCount -= 1
                        checkUpdateHandler()
                    }
                }
            } catch {
                print(error)
            }
        }
    }
    
    
//
//    func saveItemListwithInitializeAnalysis(itemList : [DocumentItem]) {
//        for item in itemList{
//            guard let waveformAnalyzer = WaveformAnalyzer(audioAssetURL: item.url) else {return}
//            let duration = 1 * 60
//            let width = duration * 10
//            let count = Int(width * 3 / 2)
//            waveformAnalyzer.samples(count: count) { samples in
//                let audio = AudioData(
//                    fileSystemFileNumber: item.fileSystemFileNumber,
//                    creationDate : item.creationDate,
//                    currentTime: 0.0,
//                    waveAnalysis: samples ?? [0.0]
//                )
//
//                self.saveAudio(audioData: audio)
//            }
//        }
//        //        audioList = fetchAudio()
//    }
}

