//
//  MessageList.swift
//  Riko
//
//  Created by Yuki Yoshioka on 2017/03/04.
//  Copyright © 2017年 Yoshitaka Kazue. All rights reserved.
//

import Foundation
import RealmSwift

class RealmManager {
    static let sharedInstance : RealmManager = {
        let instance = RealmManager()
        return instance
    }()

//    func genetateId() -> Int {
//        let userDefaults = UserDefaults.standard;
//        var currentId = userDefaults.integer(forKey: "MessageId")
//        currentId += 1;
//        userDefaults.set(currentId, forKey: "MessageId")
//        userDefaults.synchronize()
//        return currentId
//    }
    
    func add(message: Message) {
        let realm = try! Realm()
        
        try! realm.write {
            realm.add(message)
        }
    }
    
    func addMessage(id: String?, body:String?, name:String?, date:Date?) {
        let realm = try! Realm()

        let message = Message()
        message.id = id
        message.body = body
        message.name = name
        message.date = date
        try! realm.write {
            realm.add(message)
        }
    }
    
    func isExists(id: String) -> Bool {
        let realm = try! Realm()

        if realm.objects(Message.self).filter("id = %s", id).first != nil {
            return true
        } else {
            return false
        }
    }
    
    func getMessages() -> [Message] {
        let realm = try! Realm()

        var result = [Message]()
        
        for message in realm.objects(Message.self).sorted(byKeyPath: "date", ascending: false) {
            result.append(Message(value: message))
        }
        return result
    }
    
    func delete(byId:String) {
        let realm = try! Realm()

        var deleteList = [Message]()
        for message in realm.objects(Message.self).filter("id == %@", byId) {
            deleteList.append(message)
        }
        try! realm.write {
            for deleteTarget in deleteList {
                realm.delete(deleteTarget)
            }
        }
    }
}
