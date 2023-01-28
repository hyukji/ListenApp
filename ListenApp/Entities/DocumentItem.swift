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

struct DocumentItem {
    var title : String
    var folder : String
    let url : URL
    let creationDate : Date
    let size : UInt64
    let AudioExtension : String?
    let type : DocumentItemType
}


