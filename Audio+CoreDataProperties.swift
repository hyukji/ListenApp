//
//  Audio+CoreDataProperties.swift
//  
//
//  Created by 곽지혁 on 2023/02/15.
//
//

import Foundation
import CoreData


extension Audio {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Audio> {
        return NSFetchRequest<Audio>(entityName: "Audio")
    }

    @NSManaged public var creationDate: Date?
    @NSManaged public var currentTime: Double
    @NSManaged public var duration: Double
    @NSManaged public var fileSystemFileNumber: Int64
    @NSManaged public var waveAnalysis: [Float]?
    @NSManaged public var section: Section?

}
