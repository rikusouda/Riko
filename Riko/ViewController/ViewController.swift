//
//  ViewController.swift
//  Riko
//
//  Created by Yoshitaka Kazue on 2017/03/04.
//  Copyright © 2017年 Yoshitaka Kazue. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if !FirebaseManager.sharedInstance.isLogin() {
//            DispatchQueue.main.async {
//                self.present(LoginViewController.viewController(), animated: true, completion: nil)
//            }
//        } else {
//            log?.debug("ログイン済み")
//        }
        
        
        //        var messageData = FirebaseManager.Massage()
        //        messageData.body = "こんにちは"
        //        messageData.name = "Riko初号機"
        //        messageData.date = Date()
        //
        //        FirebaseManager.sharedInstance.sendMassage(message: messageData)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

