//
//  FirebaseManager.swift
//  Riko
//
//  Created by katsuya on 2017/03/04.
//  Copyright © 2017年 Yoshitaka Kazue. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class FirebaseManager {
    struct Message {
        var id: String?
        var body: String?
        var name: String?
        var userID: String?
        var date: Date?
    }
    
    let messagePath = "message"
    var databaseRef: FIRDatabaseReference!
    var delegate: ((FirebaseManager.Message)->Void)?
    
    static let sharedInstance : FirebaseManager = {
        let instance = FirebaseManager()
        return instance
    }()
    
    init() {
        databaseRef = FIRDatabase.database().reference()
    }
    
    // MARK: - Public Methods

    func setup() {
        databaseRef.child(messagePath).observe(.childAdded, with: { (snapshot) in
            log?.debug(snapshot)
            self.recevieMessage(snapshot)
        })
    }
    
    func isLogin() -> Bool {
        return FIRAuth.auth()?.currentUser != nil
    }
    
    func logout() {
        try! FIRAuth.auth()?.signOut()
    }
    
    func login(mail: String, password: String, completion: @escaping (Bool)->Void) {
        FIRAuth.auth()?.signIn(withEmail: mail, password: password, completion: { (user, error) in
            if let error = error {
                log?.error(error.localizedDescription)
                FIRAuth.auth()?.createUser(withEmail: mail, password: password, completion: { (user, error) in
                    if let error = error {
                        log?.error(error.localizedDescription)
                        completion(false)
                    } else {
                        completion(true)
                    }
                })
            } else {
                completion(true)
            }
        })
    }
    
    func sendMessage(body: String, name: String) {
        let timeInterval = Date().timeIntervalSince1970 / 1000
        
        if let userID = FIRAuth.auth()?.currentUser?.uid {
            let messageData = ["body":body, "name":name, "user_id":userID, "date":timeInterval] as [String : Any]
            databaseRef.child(messagePath).childByAutoId().setValue(messageData)
        }
    }
    
    // MARK: - Private Methods
    
    fileprivate func recevieMessage(_ snapshot: FIRDataSnapshot) {
        guard let delegate = delegate else {
            log?.debug("delegateが未設定だよ")
            return
        }
        
        if let message = snapshot.value as? [String : Any] {
            var result = Message()
            result.id = snapshot.key
            result.body = message["body"] as? String
            result.name = message["name"] as? String
            result.userID = message["user_id"] as? String
            
            if let timeInterval = message["date"] as? TimeInterval {
                let date = Date.init(timeIntervalSince1970: timeInterval * 1000)
                result.date = date
            }
            
            // 自分のメッセージは投げない
            if result.userID == FIRAuth.auth()?.currentUser?.uid {
                return
            }
            
            delegate(result)
        }
    }
}
