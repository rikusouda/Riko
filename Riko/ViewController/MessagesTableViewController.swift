import UIKit
import AVFoundation

class MessagesTableViewController: UITableViewController {
    
    private var talker = AVSpeechSynthesizer()
    var messageArray: [Message] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageArray = RealmManager.sharedInstance.getMessages()
        tableView.reloadData()
    }
    
    @IBAction func didTapCloseButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return MessagesTableViewCell.height
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messageArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessagesTableViewCell", for: indexPath) as! MessagesTableViewCell
        cell.nameLabel.text = message.name ?? ""
        cell.messageLabel.text = message.body ?? ""
        
        if let date = message.date {
            let formatter = DateFormatter()
            formatter.calendar = Calendar.current
            formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
            cell.dateLabel.text = formatter.string(from: date)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let text = messageArray[indexPath.row].body {
            let utterance = AVSpeechUtterance(string: text)
            utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
            self.talker.speak(utterance)
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return messageArray.count
    }
}
