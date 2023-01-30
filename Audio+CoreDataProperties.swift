//
//  Audio+CoreDataProperties.swift
//  
//
//  Created by 곽지혁 on 2023/01/30.
//
//

import Foundation
import CoreData


extension Audio {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Audio> {
        return NSFetchRequest<Audio>(entityName: "Audio")
    }

    @NSManaged public var audioExtension: String?
    @NSManaged public var creationDate: Date?
    @NSManaged public var currentTime: Double
    @NSManaged public var duration: Double
    @NSManaged public var location: String?
    @NSManaged public var title: String?
    @NSManaged public var waveAnalysis: [Float]?

}
