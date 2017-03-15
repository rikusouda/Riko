import UIKit

class MessagesTableViewCell: UITableViewCell {
    static let height: CGFloat = 70
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
}
