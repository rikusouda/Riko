//
//  Message.swift
//  Riko
//
//  Created by Yuki Yoshioka on 2017/03/04.
//  Copyright © 2017年 Yoshitaka Kazue. All rights reserved.
//

import Foundation
import RealmSwift

class Message : Object {
    dynamic var id: String? = ""
    dynamic var body: String? = nil
    dynamic var name: String? = nil
    dynamic var userID: String? = nil
    dynamic var date: Date? = nil
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
