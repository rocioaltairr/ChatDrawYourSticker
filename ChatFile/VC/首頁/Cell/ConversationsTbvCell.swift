//
//  TableViewCell.swift
//  ChatFile
//
//  Created by 白白 on 2021/8/12.
//

import UIKit

class ConversationsTbvCell: UITableViewCell {

    @IBOutlet weak var vwImg: UIImageView!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbMessage: UILabel!
    @IBOutlet weak var lbTime: UILabel!
    
    var conversationTbvCellViewModel : ConversationCellViewModel? {
        didSet {
            self.vwImg.image = UIImage(data: conversationTbvCellViewModel?.imageData ?? Data())
            self.lbName.text = conversationTbvCellViewModel?.strName
            self.lbMessage.text = conversationTbvCellViewModel?.strMessage
            self.lbTime.text = conversationTbvCellViewModel?.strTime
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        vwImg.contentMode = .scaleAspectFill
        vwImg.layer.masksToBounds = false
        vwImg.layer.cornerRadius = vwImg.frame.height/2
        vwImg.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
