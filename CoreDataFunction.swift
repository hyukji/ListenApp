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
        let entity = NSEntityDescription.entity(forEntityName: "Audio", in: context)
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
        
        return fetchedList
    }
//
//    // title이 같은 데이터 찾아서 해당 데이터 업데이트
//    func updateAudio(newAudio : AudioData) {
//        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Audio")
//        fetchRequest.predicate = NSPredicate(format: "title = %@", newAudio.title)
//
//        do {
//            let result = try context.fetch(fetchRequest)
//            let audio = result[0]
//            audio.setValue(newAudio.uuid, forKey: "uuid")
//            audio.setValue(newAudio.waveImage.pngData(), forKey: "waveImage")
//            audio.setValue(newAudio.mainImage.pngData(), forKey: "mainImage")
//            audio.setValue(newAudio.title, forKey: "title")
//            audio.setValue(newAudio.currentTime, forKey: "currentTime")
//            do {
//                try context.save()
//            } catch {
//                print(error)
//            }
//        } catch {
//            print(error)
//        }
//    }
//

    func deleteAudio(willdeleteAudio : AudioData) {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Audio")
        fetchRequest.predicate = NSPredicate(
            format: "title == %@ || location == %@", willdeleteAudio.title, willdeleteAudio.location
        )

        do {
            let result = try context.fetch(fetchRequest)
            for obj in result {
                context.delete(obj)
            }
            do {
                try context.save()
            } catch {
                print(error)
            }
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
