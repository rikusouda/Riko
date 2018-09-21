import UIKit
import RxSwift
import RxCocoa
import Speech

class MessageTextFieldViewController: UIViewController, SFSpeechRecognizerDelegate {

    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    @IBOutlet weak var soundLabel: UILabel!
    @IBOutlet weak var microphoneButton: UIButton!
    
    @IBAction func didTapCloseButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapMicrophoneButton(_ sender: UIButton) {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            microphoneButton.isEnabled = false
            microphoneButton.setTitle("✋", for: .disabled)
        } else {
            try! startRecording()
            microphoneButton.setTitle("🛑", for: [])
        }
    }
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var handleSendButton: UIButton!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        speechRecognizer.delegate = self
        microphoneButton.isEnabled = false
        
        handleSendButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                if let text = self.textField.text {
                    FirebaseManager.sharedInstance.sendMessage(body: text, name: UserDefaultsUtil.rikoName)
                }
                
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            })
            .disposed(by: self.disposeBag)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        requestRecognizerAuthorization()
    }
    
    private func requestRecognizerAuthorization() {
        // 認証処理
        SFSpeechRecognizer.requestAuthorization { authStatus in
            // メインスレッドで処理したい内容のため、OperationQueue.main.addOperationを使う
            OperationQueue.main.addOperation { [weak self] in
                guard let `self` = self else { return }
                
                switch authStatus {
                case .authorized:
                    self.microphoneButton.isEnabled = true
                    
                case .denied:
                    self.microphoneButton.isEnabled = false
                    self.microphoneButton.setTitle("音声認識へのアクセスが拒否されています。", for: .disabled)
                    
                case .restricted:
                    self.microphoneButton.isEnabled = false
                    self.microphoneButton.setTitle("この端末で音声認識はできません。", for: .disabled)
                    
                case .notDetermined:
                    self.microphoneButton.isEnabled = false
                    self.microphoneButton.setTitle("音声認識はまだ許可されていません。", for: .disabled)
                }
            }
        }
    }
    
    private func startRecording() throws {
        refreshTask()
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .default)
        try audioSession.setMode(.measurement)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }
        
        // 録音が完了する前のリクエストを作るかどうかのフラグ。
        // trueだと現在-1回目のリクエスト結果が返ってくる模様。falseだとボタンをオフにしたときに音声認識の結果が返ってくる設定。
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let `self` = self else { return }
            
            var isFinal = false
            
            if let result = result {
                self.textField.text = result.bestTranscription.formattedString
                isFinal = result.isFinal
            }
            
            // エラーがある、もしくは最後の認識結果だった場合の処理
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.microphoneButton.isEnabled = true
                self.microphoneButton.setTitle("🎤", for: [])
            }
        }
        
        // マイクから取得した音声バッファをリクエストに渡す
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        try startAudioEngine()
    }
    
    private func refreshTask() {
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
    }
    
    private func startAudioEngine() throws {
        // startの前にリソースを確保しておく。
        audioEngine.prepare()
        
        try audioEngine.start()
        
        soundLabel.text = "喋ってほしいな"
    }
}
