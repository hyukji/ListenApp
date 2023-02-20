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
        guard let sectionEntity = NSEntityDescription.entity(forEntityName: "Section", in: self.context) else {return}
        let section = NSManagedObject(entity: sectionEntity, insertInto: context)
        section.setValue(audioData.sectionStart, forKey: "sectionStart")
        section.setValue(audioData.sectionEnd, forKey: "sectionEnd")
        
        let entity = NSEntityDescription.entity(forEntityName: "Audio", in: self.context)
        if let entity = entity {
            let audio = NSManagedObject(entity: entity, insertInto: context)

            audio.setValue(audioData.fileSystemFileNumber, forKey: "fileSystemFileNumber")
            audio.setValue(audioData.creationDate, forKey: "creationDate")
            audio.setValue(audioData.currentTime, forKey: "currentTime")
            audio.setValue(audioData.duration, forKey: "duration")
            audio.setValue(audioData.waveAnalysis, forKey: "waveAnalysis")
            audio.setValue(section, forKey: "section")

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
                
                let waveSection = data.value(forKey: "section") as! NSManagedObject
                let sectionStart = waveSection.value(forKey: "sectionStart") as! [Int]
                let sectionEnd = waveSection.value(forKey: "sectionEnd") as! [Int]
                
                fetchedList.append(
                    AudioData(
                        fileSystemFileNumber : fileSystemFileNumber,
                        creationDate: creationDate,
                        currentTime: currentTime,
                        duration: duration,
                        waveAnalysis: waveAnalysis,
                        sectionStart: sectionStart,
                        sectionEnd : sectionEnd
                    )
                )
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        print("fetch CoreData")
        
        fetchedList.forEach {
            print("\($0.fileSystemFileNumber) waveAnalysis.count = \($0.waveAnalysis.count), section.count = \($0.sectionStart.count)")
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

    func resetAllRecords() {
        let audioDeleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Audio")
        let audioDeleteRequest = NSBatchDeleteRequest(fetchRequest: audioDeleteFetch)
        
        do
        {
            try context.execute(audioDeleteRequest)
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
//        self.delAudioDataIsnotInPlayList(playList: playList)
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
                    duration: player.duration,
                    waveAnalysis: [0.0],
                    sectionStart: [0],
                    sectionEnd: [0]
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
                        let analysis = self.saveAnalysisSection(samples: waveAnalysis)
                        audio.setValue(waveAnalysis, forKey: "waveAnalysis")
                        audio.setValue(analysis, forKey: "section")
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
    
    func saveAnalysisSection(samples : [Float]) -> NSManagedObject {
        guard let entity = NSEntityDescription.entity(forEntityName: "Section", in: self.context) else { return NSManagedObject() }
        
        var isSilence = true
        var cnt = 0
        var sectionStart : [Int] = []
        var sectionEnd : [Int] = []
        
        for (idx, data) in samples.enumerated() {
            if isSilence {
                // 무음이다가 소리가 들린다면
                if data < 0.8 {
                    isSilence = false
                    sectionStart.append(idx)
                }
            }
            else {
                if data > 0.8 {
                    // 소리가 들리다가 조용해 진다며
                    cnt += 1
                    if cnt == 1 {
                        sectionEnd.append(idx)
                    } else if cnt > 10 {
                        isSilence = true
                        cnt = 0
                    }
                } else if cnt > 0 {
                    // 소리가 계속해서 들리는 데 cnt가 0보다 크다면
                    sectionEnd.removeLast()
                    cnt = 0
                }
            }
        }
        
        let analysis = NSManagedObject(entity: entity, insertInto: context)
        analysis.setValue(sectionStart, forKey: "sectionStart")
        analysis.setValue(sectionEnd, forKey: "sectionEnd")
        print("sectionStart saved! \(sectionStart.count)")
        print("sectionEnd saved! \(sectionStart.count)")

    
        return analysis
        
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

