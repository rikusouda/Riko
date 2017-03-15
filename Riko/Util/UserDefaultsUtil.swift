//
//  UserDefaultsUtil.swift
//  Riko
//
//  Created by katsuya on 2017/03/04.
//  Copyright © 2017年 Yoshitaka Kazue. All rights reserved.
//

import Foundation

class UserDefaultsUtil {
    static let rikoNameKey = "uc_riko_name_key"
    static let userDefaults = UserDefaults.standard

    static var rikoName: String {
        get {
            let result = userDefaults.string(forKey: rikoNameKey) ?? ""
            return result
        }
        set(msg) {
            userDefaults.set(msg, forKey: rikoNameKey)
            userDefaults.synchronize()
        }
    }
}
