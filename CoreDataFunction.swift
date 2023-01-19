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
    
    func getDocumentFileURL(title : String) -> URL {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let finalURL = documentsURL.appendingPathComponent("\(title).mp3")
        
        return finalURL
    }
    
    func initializeSave(title : String) {
        let url = getDocumentFileURL(title: title)
        
        let waveformImageDrawer = WaveformImageDrawer()
        waveformImageDrawer.waveformImage(
            fromAudioAt: url,
            with: .init(
                size : CGSize(width: 3530 * 5, height: 300),
                style: .striped(.init(color: .tintColor)),
                dampening: nil,
                verticalScalingFactor: 0.5 )) { image in
            // need to jump back to main queue
            DispatchQueue.main.async {
                let audio = NowAudio(
                    waveImage: image ?? UIImage(),
                    mainImage: UIImage(named: "MusicBasic") ?? UIImage(),
                    title: title,
                    currentTime: 0.0
                )
                self.saveAudio(nowAudio: audio)
            }
        }
    }
    
    
    func saveAudio(nowAudio : NowAudio) {
        let entity = NSEntityDescription.entity(forEntityName: "Audio", in: context)
        if let entity = entity {
            let audio = NSManagedObject(entity: entity, insertInto: context)
            
            audio.setValue(nowAudio.uuid, forKey: "uuid")
            audio.setValue(nowAudio.waveImage.pngData(), forKey: "waveImage")
            audio.setValue(nowAudio.mainImage.pngData(), forKey: "mainImage")
            audio.setValue(nowAudio.title, forKey: "title")
            audio.setValue(nowAudio.currentTime, forKey: "currentTime")
            
            do {
                try context.save()
                print("saved!")
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    
    func fetchAudio() -> [NowAudio] {
        var audioList : [NowAudio] = []
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Audio")
        do {
            let result = try context.fetch(fetchRequest)
            for data in result {
                let title = data.value(forKey: "title") as! String
                let mainImage = data.value(forKey: "mainImage") as? Data ?? Data()
                let waveImage = data.value(forKey: "waveImage") as? Data ?? Data()
                let currentTime = data.value(forKey: "currentTime") as! Double
                
                audioList.append(
                    NowAudio(
                        waveImage: UIImage(data: waveImage) ?? UIImage(),
                        mainImage: UIImage(data: mainImage) ?? UIImage(),
                        title: title,
                        currentTime: currentTime
                    )
                )
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return audioList
    }
    
    // title이 같은 데이터 찾아서 해당 데이터 업데이트
    func updateAudio(newAudio : NowAudio) {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Audio")
        fetchRequest.predicate = NSPredicate(format: "title = %@", newAudio.title)
        
        do {
            let result = try context.fetch(fetchRequest)
            let audio = result[0]
            audio.setValue(newAudio.uuid, forKey: "uuid")
            audio.setValue(newAudio.waveImage.pngData(), forKey: "waveImage")
            audio.setValue(newAudio.mainImage.pngData(), forKey: "mainImage")
            audio.setValue(newAudio.title, forKey: "title")
            audio.setValue(newAudio.currentTime, forKey: "currentTime")
            do {
                try context.save()
            } catch {
                print(error)
            }
        } catch {
            print(error)
        }
    }
    
    
    func deleteAudio(willdeleteAudio : NowAudio) {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Audio")
        fetchRequest.predicate = NSPredicate(format: "title = %@", willdeleteAudio.title)
        
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
    
}
