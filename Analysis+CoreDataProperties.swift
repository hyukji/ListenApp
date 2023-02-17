//
//  Analysis+CoreDataProperties.swift
//  
//
//  Created by 곽지혁 on 2023/02/15.
//
//

import Foundation
import CoreData


extension Analysis {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Analysis> {
        return NSFetchRequest<Analysis>(entityName: "Analysis")
    }

    @NSManaged public var sectionStart: [Int]?
    @NSManaged public var audio: Audio?

}
