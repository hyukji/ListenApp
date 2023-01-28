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
    var appDelegate : AppDelegate!
    var context : NSManagedObjectContext!
    
    
    init() {
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        context = appDelegate.persistentContainer.viewContext
    }
    
    
    func initializeSave(item : DocumentItem) {
        print("initil")
        let waveformImageDrawer = WaveformImageDrawer()
        waveformImageDrawer.waveformImage(
            fromAudioAt: item.url,
            with: .init(
                size : CGSize(width: 500, height: 300),
                style: .striped(.init(color: .tintColor)),
                dampening: nil,
                scale: UIScreen.main.scale * 0.5,
                verticalScalingFactor: 0.3 )) { image in
            // need to jump back to main queue
            DispatchQueue.main.async {
                print("image maked")
                let audio = AudioData(
                                      title: item.title,
                                      folder : item.folder,
                                      audioExtension: item.AudioExtension ?? "",
                                      waveImage: image ?? UIImage(),
                                      waveAnalysis: [0.0],
                                      currentTime: 0.0,
                                      duration: 0.0,
                                      creationDate: item.creationDate)
                
                self.saveAudio(audioData: audio)
            }
        }
    }
    
//    size: CGSize = .zero,
//    backgroundColor: UIColor = UIColor.clear,
//    style: Style = .gradient([UIColor.black, UIColor.gray]),
//    dampening: Dampening? = nil,
//    position: Position = .middle,
//    scale: CGFloat = UIScreen.main.scale,
//    verticalScalingFactor: CGFloat = 0.95,
//    shouldAntialias: Bool = false) {

    
    
    func saveAudio(audioData : AudioData) {
        print("save")
        let entity = NSEntityDescription.entity(forEntityName: "Audio", in: context)
        if let entity = entity {
            let audio = NSManagedObject(entity: entity, insertInto: context)

            audio.setValue(audioData.title, forKey: "title")
            audio.setValue(audioData.folder, forKey: "folder")
            audio.setValue(audioData.audioExtension, forKey: "audioExtension")
            audio.setValue(audioData.waveImage.pngData(), forKey: "waveImage")
            audio.setValue(audioData.currentTime, forKey: "currentTime")
            audio.setValue(audioData.duration, forKey: "duration")
            audio.setValue(audioData.creationDate, forKey: "creationDate")

            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: audioData.waveAnalysis, requiringSecureCoding: false)
                audio.setValue(data, forKey: "waveAnalysis")
                try context.save()
                print("saved!")
            } catch {
                print(error.localizedDescription)
            }
        }
    }


    // 저장된 audio 데이터 가져와 AudioData instance list
    func fetchAudio() -> [AudioData] {
        var audioList : [AudioData] = []
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Audio")
        do {
            let resultList = try context.fetch(fetchRequest)
            for data in resultList {
                
                let title = data.value(forKey: "title") as! String
                let folder = data.value(forKey: "folder") as! String
                let audioExtension = data.value(forKey: "audioExtension") as! String
                let waveImage = data.value(forKey: "waveImage") as? Data ?? Data()
                let waveAnalysis = data.value(forKey: "waveAnalysis") as? [Double] ?? []
                let currentTime = data.value(forKey: "currentTime") as! Double
                let duration = data.value(forKey: "duration") as! Double
                let creationDate = data.value(forKey: "creationDate") as! Date
                
                audioList.append(
                    AudioData(
                              title: title,
                              folder: folder,
                              audioExtension: audioExtension,
                              waveImage: UIImage(data: waveImage) ?? UIImage(),
                              waveAnalysis: waveAnalysis,
                              currentTime: currentTime,
                              duration: duration,
                              creationDate: creationDate)
                )
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return audioList
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

//    func deleteAudio(willdeleteAudio : AudioData) {
//        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Audio")
//        fetchRequest.predicate = NSPredicate(format: "title = %@", willdeleteAudio.title)
//
//        do {
//            let result = try context.fetch(fetchRequest)
//            for obj in result {
//                context.delete(obj)
//            }
//            do {
//                try context.save()
//            } catch {
//                print(error)
//            }
//        } catch {
//            print(error)
//        }
//    }
    
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
