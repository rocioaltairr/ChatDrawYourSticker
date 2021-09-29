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
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
