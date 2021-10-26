//
//  CustomInputAccessoryView.swift
//  ChatGame
//
//  Created by 2008007NB01 on 2021/2/5.
//

import UIKit
import MessageKit
import ISEmojiView

protocol CustomInputAccessoryViewDelegate {
    func inputView(_ inputView: CustomInputAccessoryView,wantsToSend message: String)
    func presentAdd()
    func presentCamera()
    func presentAlbum()
    
}
class CustomInputAccessoryView: UIView {

    var delegate:CustomInputAccessoryViewDelegate?
    
    let messageInputTextView: UITextView = {
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
        btn.tintColor = .black
        return btn
    }()
    
    private lazy var btnAddCamera: UIButton = { // because is inside the UIView , and we try to add target inside the closure
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "icons8-camera-96"), for: .normal)
        btn.addTarget(self, action: #selector(handleAddCamera), for: .touchUpInside)
        btn.tintColor = .black
        return btn
    }()
    
    private lazy var btnAddLibraryPhoto: UIButton = { // because is inside the UIView , and we try to add target inside the closure
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "icons8-picture-144 (1)"), for: .normal)
        btn.addTarget(self, action: #selector(handleAddAlbum), for: .touchUpInside)
        btn.tintColor = .black
        return btn
    }()
    
    private lazy var btnSend: UIButton = { // because is inside the UIView , and we try to add target inside the closure
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "icons8-send-64"), for: .normal)
        btn.addTarget(self, action: #selector(handleSendMessage), for: .touchUpInside)
        btn.tintColor = #colorLiteral(red: 0.768627451, green: 0.768627451, blue: 0.768627451, alpha: 1)
        return btn
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let lb = UILabel()
        lb.text = "輸入訊息"
        lb.font = UIFont.systemFont(ofSize: 16)
        lb.textColor = .lightGray
        return lb
    }()
    
    func dismissKeyboard1() {
        messageInputTextView.text = nil
        placeholderLabel.isHidden = false
        self.messageInputTextView.endEditing(true)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        autoresizingMask = .flexibleHeight
        layer.shadowOpacity = 0.25
        layer.shadowOffset = .init(width: 0, height: -8)
        layer.shadowColor = UIColor.lightGray.cgColor
        backgroundColor = .white
        

        
        addSubview(btnAdd) // 新增
        btnAdd.anchor(left: leftAnchor,paddingLeft: 12)
        btnAdd.setDimensions(height: 30, width: 30)
        btnAdd.centerY(inView: self)
        
        addSubview(btnAddCamera) // 拍照
        btnAddCamera.anchor(left: btnAdd.rightAnchor,paddingLeft: 12)
        btnAddCamera.setDimensions(height: 30, width: 30)
        btnAddCamera.centerY(inView: self)
        
        addSubview(btnAddLibraryPhoto) // 相簿
        btnAddLibraryPhoto.anchor(left: btnAddCamera.rightAnchor,paddingLeft: 12)
        btnAddLibraryPhoto.setDimensions(height: 30, width: 30)
        btnAddLibraryPhoto.centerY(inView: self)
        
        addSubview(btnSend) // 送出訊息button
        btnSend.anchor(right: rightAnchor,paddingRight: 12)
        btnSend.setDimensions(height: 30, width: 30)
        btnSend.centerY(inView: self)
        
        let keyboardSettings = KeyboardSettings(bottomType: .categories)
        let emojiView = EmojiView(keyboardSettings: keyboardSettings)
        emojiView.translatesAutoresizingMaskIntoConstraints = false
        emojiView.delegate = self
        
        addSubview(messageInputTextView) // 聊天輸入框
        messageInputTextView.inputView = emojiView
        
        messageInputTextView.anchor(top:topAnchor, left: btnAddLibraryPhoto.rightAnchor, bottom: safeAreaLayoutGuide.bottomAnchor,
                                    right: btnSend.leftAnchor, paddingLeft: 4, paddingRight: 12)
        messageInputTextView.setHeight(height:  55)
       // messageInputTextView.centerY(inView: self)
        
        addSubview(placeholderLabel) // 聊天輸入框placeholder
        placeholderLabel.anchor(top:topAnchor, left: btnAddLibraryPhoto.rightAnchor, bottom: safeAreaLayoutGuide.bottomAnchor,
                                right: btnSend.leftAnchor, paddingLeft: 4, paddingRight:12)
        placeholderLabel.setHeight(height: 55)
        
        
       // placeholderLabel.centerY(inView: self)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextInputChange), name: UITextView.textDidChangeNotification, object: nil)
        
    }
    
    @objc func handleSendMessage() { // 送出訊息button
        if self.messageInputTextView.text.isEmpty == false {

            guard let message = messageInputTextView.text else { return }
            delegate?.inputView(self,wantsToSend: message)
        } else {
        }
        
    }
    
    @objc func handleAdd() { // 新增媒體
        delegate?.presentAdd()
    }
    
    @objc func handleAddCamera() { // 新增相簿
        delegate?.presentCamera()
    }
    
    @objc func handleAddAlbum() { // 新增拍照
        delegate?.presentAlbum()
    }
    
    @objc func handleTextInputChange() {
        if self.messageInputTextView.text.isEmpty {
            btnSend.setImage(UIImage(named: "icons8-send-64"), for: .normal)
            btnSend.tintColor = #colorLiteral(red: 0.768627451, green: 0.768627451, blue: 0.768627451, alpha: 1)
            btnSend.isEnabled = false
        } else {
            btnSend.isEnabled = true
            btnSend.tintColor = .systemBlue
            btnSend.setImage(UIImage(named: "icons8-send-234"), for: .normal)
        }
        placeholderLabel.isHidden = !self.messageInputTextView.text.isEmpty
    }
    
//    @objc func presentInputActionSheet() {
//        delegate?.presentActionSheet()
//
//    }
    
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

extension CustomInputAccessoryView: EmojiViewDelegate {
    func emojiViewDidSelectEmoji(_ emoji: String, emojiView: EmojiView) {
        messageInputTextView.insertText(emoji)
    }
    
    func emojiViewDidPressChangeKeyboardButton(_ emojiView: EmojiView) {
        messageInputTextView.inputView = nil
        messageInputTextView.keyboardType = .default
        messageInputTextView.reloadInputViews()
    }
    
    func emojiViewDidPressDeleteBackwardButton(_ emojiView: EmojiView) {
        messageInputTextView.deleteBackward()
    }
    
    func emojiViewDidPressDismissKeyboardButton(_ emojiView: EmojiView) {
        messageInputTextView.resignFirstResponder()
    }
}
