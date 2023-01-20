//
//  DocumentItem.swift
//  ListenApp
//
//  Created by 곽지혁 on 2023/01/21.
//

import Foundation

enum DocumentItemType {
    case folder
    case file
}

struct DocumentItem {
    let title : String
    let url : URL
    let type : DocumentItemType
}
