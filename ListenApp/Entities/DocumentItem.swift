//
//  DocumentItem.swift
//  ListenApp
//
//  Created by 곽지혁 on 2023/01/21.
//

import Foundation

enum DocumentItemType : Comparable {
    case folder
    case file
}

struct DocumentItem : Equatable {
    var title : String
    var location : String
    let url : URL
    let creationDate : Date
    let fileSystemFileNumber : Int
    let size : UInt64
    let audioExtension : String?
    let type : DocumentItemType
    
    static func == (lhs: DocumentItem, rhs: DocumentItem) -> Bool {
        return (lhs.title == rhs.title
                && lhs.location == rhs.location
                && lhs.creationDate == rhs.creationDate
                && lhs.size == rhs.size
                && lhs.audioExtension == rhs.audioExtension)
    }
    
    static func != (lhs: DocumentItem, rhs: DocumentItem) -> Bool {
        return (lhs.title != rhs.title
                || lhs.location != rhs.location
                || lhs.creationDate != rhs.creationDate
                || lhs.size != rhs.size
                || lhs.audioExtension != rhs.audioExtension)
    }
}


