//
//  MessageCVCell.swift
//  ChatGame
//
//  Created by 2008007NB01 on 2021/2/8.
//

import UIKit

class MessageCVCell: UICollectionViewCell {
    
    var message: Message? {
        didSet { configure() }
    }
    
    var userImgName: String?
    
    var bubbleLeftAnchor: NSLayoutConstraint!
    var bubbleRightAnchor: NSLayoutConstraint!
    
    lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .black
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    private let textView: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = .clear
        tv.textColor = .white
        tv.font = .systemFont(ofSize: 16)
        tv.isScrollEnabled = false
        tv.isEditable = false
        tv.text = "Some test"
        return tv
    }()
    
    private let lbReadStatus: UILabel = {
        let lb = UILabel()
        lb.text = "Read"
        lb.font = UIFont.systemFont(ofSize: 16)
        lb.textColor = .lightGray
        return lb
    }()
    
    private let bubbleContainer: UIView = {
        let vw = UIView()
        vw.backgroundColor = .systemPurple
        return vw
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // 大頭貼
        addSubview(profileImageView)
        
        profileImageView.anchor(left: leftAnchor,bottom: bottomAnchor, paddingLeft: 12, paddingBottom: 5)
        profileImageView.setDimensions(height: 30, width: 30)
        profileImageView.layer.cornerRadius = 15

        // 聊天泡泡
        addSubview(bubbleContainer)
        bubbleContainer.layer.cornerRadius = 12
        bubbleContainer.anchor(top: topAnchor, bottom: bottomAnchor)
        bubbleContainer.widthAnchor.constraint(lessThanOrEqualToConstant: 250).isActive = true
        
        bubbleLeftAnchor = bubbleContainer.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 12)
        bubbleLeftAnchor.isActive = false
        bubbleRightAnchor = bubbleContainer.rightAnchor.constraint(equalTo: rightAnchor, constant: -12)
        bubbleRightAnchor.isActive = false
        
        // 輸入框
        bubbleContainer.addSubview(textView)
        textView.anchor(top: bubbleContainer.topAnchor, left: bubbleContainer.leftAnchor, bottom: bubbleContainer.bottomAnchor, right: bubbleContainer.rightAnchor, paddingTop: 5, paddingLeft: 12, paddingBottom: 5, paddingRight: 12)
        
        addSubview(lbReadStatus)
        

    }
    
    func configure() {
        guard let message = message else { return }
        let viewModel = MessageViewModel(message: message)
        
        bubbleContainer.backgroundColor = viewModel.messageBackgroundColor
        textView.textColor = viewModel.messageTextColor
        textView.text = message.text
        
        bubbleLeftAnchor.isActive = viewModel.leftAnchorActive
        bubbleRightAnchor.isActive = viewModel.rightAnchorActive
        
        profileImageView.isHidden = viewModel.shouldHideProfileImage

        
        for view in self.subviews{
            if view == lbReadStatus {
                view.removeFromSuperview()
            }
        }
        
        
        addSubview(lbReadStatus)
        if viewModel.leftAnchorActive == true {
            lbReadStatus.anchor(left:bubbleContainer.rightAnchor,bottom: bubbleContainer.bottomAnchor,paddingLeft: 8,paddingBottom: 5)
            lbReadStatus.isHidden = true

        } else {
            lbReadStatus.anchor(bottom: bubbleContainer.bottomAnchor, right:bubbleContainer.leftAnchor,paddingBottom: 5, paddingRight: 8)
            if message.isRead == true {
                lbReadStatus.isHidden = false
            } else {
                lbReadStatus.isHidden = true
            }
        }

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
