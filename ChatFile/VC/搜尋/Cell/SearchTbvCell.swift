//
//  SearchTbvCell.swift
//  ChatFile
//
//  Created by 白白 on 2021/9/25.
//

import UIKit

class SearchTbvCell: UITableViewCell {
    @IBOutlet weak var imgUser: UIImageView!
    
    @IBOutlet weak var lbTitle: UILabel!
    override func awakeFromNib() {
        imgUser.contentMode = .scaleAspectFill
        imgUser.layer.masksToBounds = false
        imgUser.layer.cornerRadius = imgUser.frame.height/2
        imgUser.clipsToBounds = true
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
