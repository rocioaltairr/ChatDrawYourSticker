//
//  CustomInputAccessoryView.swift
//  ChatGame
//
//  Created by 2008007NB01 on 2021/2/5.
//

import UIKit

protocol CustomInputAccessoryViewDelegate {
    func inputView(_ inputView: CustomInputAccessoryView,wantsToSend message: String)
    func presentActionSheet()
}
class CustomInputAccessoryView: UIView {
    
    var delegate:CustomInputAccessoryViewDelegate?
    
    private let messageInputTextView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.isScrollEnabled = false
        tv.textColor = .darkGray
        tv.backgroundColor = .clear
        return tv
    }()
    
    private lazy var btnAdd: UIButton = { // because is inside the UIView , and we try to add target inside the closure
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "plus"), for: .normal)
        btn.addTarget(self, action: #selector(handleAdd), for: .touchUpInside)
        return btn
    }()
    
    private lazy var btnSend: UIButton = { // because is inside the UIView , and we try to add target inside the closure
        let btn = UIButton(type: .system)
        btn.setTitle("Send", for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        btn.setTitleColor(.systemPurple, for: .normal)
        btn.addTarget(self, action: #selector(handleSendMessage), for: .touchUpInside)
        return btn
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Enter Message"
        lb.font = UIFont.systemFont(ofSize: 16)
        lb.textColor = .lightGray
        return lb
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .red
        autoresizingMask = .flexibleHeight
        layer.shadowOpacity = 0.25
        layer.shadowOffset = .init(width: 0, height: -8)
        layer.shadowColor = UIColor.lightGray.cgColor
        backgroundColor = .white
        
        addSubview(btnSend) // 送出訊息button
        btnSend.anchor(top:topAnchor, right: rightAnchor, paddingTop: 4, paddingRight: 4)
        btnSend.setDimensions(height: 50, width: 50)
        
        addSubview(btnAdd) // 新增
        btnAdd.anchor(top:topAnchor, left: leftAnchor, paddingTop: 4, paddingLeft: 4)
        btnAdd.setDimensions(height: 50, width: 50)
        
        addSubview(messageInputTextView)
        messageInputTextView.anchor(top:topAnchor, left: btnAdd.rightAnchor, bottom: safeAreaLayoutGuide.bottomAnchor,
                                    right: btnSend.leftAnchor, paddingTop: 12, paddingLeft: 4,
                                    paddingBottom: 4, paddingRight: 8)
        
        addSubview(placeholderLabel) // 聊天輸入框
        placeholderLabel.anchor(left:messageInputTextView.leftAnchor, paddingLeft: 4)
        placeholderLabel.centerY(inView: messageInputTextView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextInputChange), name: UITextView.textDidChangeNotification, object: nil)
        
    }
    
    @objc func handleSendMessage() { // 送出訊息button
        guard let message = messageInputTextView.text else { return }
        delegate?.inputView(self,wantsToSend: message)
    }
    
    @objc func handleAdd() { // 新增媒體
        delegate?.presentActionSheet()
    }
    
    @objc func handleTextInputChange() {
        placeholderLabel.isHidden = !self.messageInputTextView.text.isEmpty
    }
    
    @objc func presentInputActionSheet() {
        delegate?.presentActionSheet()
   
    }
    
    func clearSendMessage() {
        messageInputTextView.text = nil
        placeholderLabel.isHidden = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("inti has not been implement")
    }
    
    override var intrinsicContentSize: CGSize {
        return .zero // in will be like the parent view constraint
    }
}
