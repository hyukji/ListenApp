//
//  Audio+CoreDataProperties.swift
//  ListenApp
//
//  Created by 곽지혁 on 2023/01/19.
//
//

import Foundation
import CoreData


extension Audio {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Audio> {
        return NSFetchRequest<Audio>(entityName: "Audio")
    }

    @NSManaged public var title: String?
    @NSManaged public var uuid: String?
    @NSManaged public var currentTime: Double
    @NSManaged public var duration: Double
    @NSManaged public var mainImage: Data?
    @NSManaged public var waveImage: Data?

}

extension Audio : Identifiable {

}
