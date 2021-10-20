//
//  TableViewCell.swift
//  ChatFile
//
//  Created by 2008007NB01 on 2021/8/12.
//

import UIKit

class ConversationsTbvCell: UITableViewCell {

    @IBOutlet weak var vwImg: UIImageView!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbMessage: UILabel!
    
    @IBOutlet weak var lbTime: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        vwImg.contentMode = .scaleAspectFill
        vwImg.layer.masksToBounds = false
        vwImg.layer.cornerRadius = vwImg.frame.height/2
        vwImg.clipsToBounds = true
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
