//
//  RikoViewController.swift
//  Riko
//
//  Created by Yoshitaka Kazue on 2017/03/04.
//  Copyright © 2017年 Yoshitaka Kazue. All rights reserved.
//

import UIKit
import AVFoundation
import RxSwift
import RxCocoa

enum RikoType: Int {
    
    case blue
    case purple
    case red
    
    var image: UIImage {
        switch self {
        case .blue:
            return UIImage(named: "riko-blue")!
        case .purple:
            return UIImage(named: "riko-purple")!
        case .red:
            return UIImage(named: "riko-red")!
        }
    }
    
}

class RikoViewController: UIViewController {
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var rikoImageView: UIImageView!
    @IBOutlet weak var historyButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    
    var previewInteraction: UIPreviewInteraction!
    let kVibrateAnimationKey = "VibrateAnimationKey"
    var shakeStart: Date?
    private var talker = AVSpeechSynthesizer()
    let disposeBag = DisposeBag()


    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        previewInteraction = UIPreviewInteraction(view: view)
        previewInteraction.delegate = self
        changeRikoType()
        shouldShowLoginViewController()
        
        MessageManager.sharedInstance.lastMessage.asObservable()
            .map { $0.body }
            .bind(to: messageLabel.rx.text)
            .disposed(by: disposeBag)
        
        MessageManager.sharedInstance.lastMessage.asObservable()
            .map { $0.body }
            .subscribe(onNext: { [unowned self] (message) in
                if !self.talker.continueSpeaking() {
                    if let body = message {
                        let utterance = AVSpeechUtterance(string: body)
                        utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
                        self.talker.speak(utterance)
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        vibrated(vibrated: true, view: rikoImageView)
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        guard event?.type == UIEventType.motion && event?.subtype == UIEventSubtype.motionShake else { return }
        
        // シェイク動作始まり時の処理
        shakeStart = Date()
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        guard event?.type == UIEventType.motion && event?.subtype == UIEventSubtype.motionShake else { return }
        
        // シェイク動作終了時の処理
        guard let shakeStart = shakeStart else { return }
        self.shakeStart = nil
        let shakeTime = Date().timeIntervalSince(shakeStart) * 5
        print(shakeTime)
        let jumpCount = Int(floor(shakeTime))
        print(jumpCount)
        let jumps = (0..<jumpCount).map { _ in self.jumpRiko() }
        Observable.from(jumps)
            .concat()
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    func degreesToRadians(degrees: Float) -> Float {
        return degrees * Float(Double.pi) / 180.0
    }
    
    func vibrated(vibrated:Bool, view: UIView) {
        if vibrated {
            var animation: CABasicAnimation
            animation = CABasicAnimation(keyPath: "transform.rotation")
            animation.duration = 0.25
            animation.fromValue = degreesToRadians(degrees: 3.0)
            animation.toValue = degreesToRadians(degrees: -3.0)
            animation.repeatCount = Float.infinity
            animation.autoreverses = true
            view.layer.add(animation, forKey: kVibrateAnimationKey)
        }
        else {
            view.layer.removeAnimation(forKey: kVibrateAnimationKey)
        }
    }
    
    func changeRikoType() {
        rikoImageView.image = RikoType(rawValue: Int(arc4random() % 3))!.image
    }
    
    func feadInRiko() {
        let transform = CGAffineTransform(translationX: 300, y: 0)
        rikoImageView.transform = transform
        UIView.animate(
            withDuration: 3,
            delay: 0,
            options: .curveEaseInOut,
            animations: { [weak self] in
                self?.rikoImageView.transform = CGAffineTransform.identity
            },
            completion: { _ in }
        )
    }
    
    func fadeOutRiko() {
        var transform = self.rikoImageView.transform
        transform = transform.translatedBy(x: 0, y: -200)
        transform = transform.scaledBy(x: 0.01, y: 0.01)
        rikoImageView.transform = transform
    }
    
    func jumpRiko() -> Observable<Any> {
        return Observable.create { observer in
            self.upRiko { [weak self] in
                self?.downRiko {
                    observer.onNext("")
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }
    
    func upRiko(completion: @escaping () -> Void) {
        let transform = CGAffineTransform(translationX: 0, y: -100)
        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            options: .curveEaseInOut,
            animations: { [weak self] in
                self?.rikoImageView.transform = transform
            },
            completion: { _ in
                completion()
            }
        )
    }
    
    func downRiko(completion: @escaping () -> Void) {
        UIView.animate(
            withDuration: 0.1,
            delay: 0,
            options: .curveEaseInOut,
            animations: { [weak self] in
                self?.rikoImageView.transform = CGAffineTransform.identity
            },
            completion: { _ in
                completion()
            }
        )
    }
    
    func shouldShowLoginViewController() {
        //        FirebaseManager.sharedInstance.logout() // ログイン画面のテストをするときはコメントアウトを外すべし
        if !FirebaseManager.sharedInstance.isLogin() {
            DispatchQueue.main.async {
                self.present(LoginViewController.viewController(), animated: true, completion: nil)
            }
        }
    }
}

extension RikoViewController: UIPreviewInteractionDelegate {
    
    func previewInteraction(_ previewInteraction: UIPreviewInteraction, didUpdatePreviewTransition transitionProgress: CGFloat, ended: Bool) {
        let scale = 1 + transitionProgress
        let transform = CGAffineTransform(scaleX: scale, y: scale)
        rikoImageView.transform = transform
    }
    
    func previewInteractionDidCancel(_ previewInteraction: UIPreviewInteraction) {
        UIView.animate(
            withDuration: 3,
            delay: 0,
            options: .curveEaseInOut,
            animations: { [weak self] in
                self?.fadeOutRiko()
            },
            completion: { [weak self] _ in
                self?.changeRikoType()
                self?.feadInRiko()
            }
        )
    }
    
}

