//
//  LoginViewController.swift
//  Riko
//
//  Created by katsuya on 2017/03/04.
//  Copyright © 2017年 Yoshitaka Kazue. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class LoginViewController: UIViewController {
    @IBOutlet weak var rikosNameLabel: UITextField!
    @IBOutlet weak var mailLabel: UITextField!
    @IBOutlet weak var errorView: UIStackView!
    @IBOutlet weak var passwordLabel: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBAction func handleLoginButton(_ sender: Any) {
    }
    @IBOutlet weak var rikoLabel: UILabel!
    @IBOutlet weak var rikoImage: UIImageView!
    
    var running = Variable<Bool>(false)
    
    static func viewController() -> LoginViewController {
        return UIStoryboard(name: "LoginViewController", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
    }
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rikoNameValid: Observable<Bool> = rikosNameLabel.rx.text
            .map{ text -> Bool in
                text?.count ?? 0 > 0
            }
            .share(replay: 1)
        
        let mailValid: Observable<Bool> = mailLabel.rx.text
            .map{ text -> Bool in
                text?.count ?? 0 > 0
            }
            .share(replay: 1)
        
        let passwordValid: Observable<Bool> = passwordLabel.rx.text
            .map{ text -> Bool in
                text?.count ?? 0 > 6
            }
            .share(replay: 1)
        
        let allValid: Observable<Bool> = Observable.combineLatest(rikoNameValid,
                                                                  mailValid,
                                                                  passwordValid,
                                                                  running.asObservable()) {
                                                                    $0 && $1 && $2 && !$3
        }
        
        allValid.bind(to: loginButton.rx.isEnabled).disposed(by: disposeBag)
        
        loginButton.rx.tap.subscribe(onNext: { [unowned self] in
            if let mail = self.mailLabel.text, let passwoard = self.passwordLabel.text {
                self.errorView.isHidden = true
                self.running.value = true

                FirebaseManager.sharedInstance.login(mail: mail,
                                                     password: passwoard,
                                                     completion: { (result) in
                                                        if result {
                                                            UserDefaultsUtil.rikoName = self.rikosNameLabel.text ?? ""
                                                            DispatchQueue.main.async {
                                                                self.dismiss(animated: true, completion: nil)
                                                            }
                                                        } else {
                                                            self.errorView.isHidden = false
                                                        }
                                                        self.running.value = false
                })
            }
        }).disposed(by: disposeBag)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
