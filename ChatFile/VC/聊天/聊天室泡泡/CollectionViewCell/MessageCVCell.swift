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
        
        tv.translatesAutoresizingMaskIntoConstraints = true
        tv.sizeToFit()
        
        
        return tv
    }()
    
    private let lbDate: UILabel = {
        let lb = UILabel()
        lb.text = "Read"
        lb.font = UIFont.systemFont(ofSize: 11)
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
        
        // 文字
        bubbleContainer.addSubview(textView)
        
        textView.text = message?.text
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        textView.frame = newFrame
        
        // textView.he
        textView.anchor(top: bubbleContainer.topAnchor, left: bubbleContainer.leftAnchor, bottom: bubbleContainer.bottomAnchor, right: bubbleContainer.rightAnchor, paddingTop: 5, paddingLeft: 12, paddingBottom: 5, paddingRight: 12)
        
        addSubview(lbDate)
        
        
    }
    
    func configure() {
        guard let message = message else { return }
        let viewModel = MessageViewModel(message: message)
        
        bubbleContainer.backgroundColor = viewModel.messageBackgroundColor
        textView.textColor = viewModel.messageTextColor
        textView.text = message.text
        
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        textView.frame = newFrame
        
        
        bubbleLeftAnchor.isActive = viewModel.leftAnchorActive
        bubbleRightAnchor.isActive = viewModel.rightAnchorActive
        profileImageView.isHidden = viewModel.shouldHideProfileImage
        
        //        for view in self.subviews{
        //            if view == lbDate {
        //                view.removeFromSuperview()
        //            }
        //        }
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let strDate = dateFormatter.string(from: (message.timestamp.dateValue()))
        lbDate.text = strDate
        
        if viewModel.leftAnchorActive == true {
            lbDate.anchor(left:bubbleContainer.rightAnchor,bottom: bubbleContainer.bottomAnchor,paddingLeft: 5,paddingBottom: 5)
        } else {
            lbDate.anchor(bottom: bubbleContainer.bottomAnchor, right:bubbleContainer.leftAnchor,paddingBottom: 5, paddingRight: 5)
            
        }

       // self.setDimensions(height: newSize.height, width: self.frame.width)
        //self.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: newSize.height)
        //CGSize(width: self.frame.width, height: newSize.height)
        //self.frame =  CGSize(width: self.frame.width, height: newSize.height)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
