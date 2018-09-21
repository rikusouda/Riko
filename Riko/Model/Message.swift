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
    @objc dynamic var id: String? = ""
    @objc dynamic var body: String? = nil
    @objc dynamic var name: String? = nil
    @objc dynamic var userID: String? = nil
    @objc dynamic var date: Date? = nil
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
