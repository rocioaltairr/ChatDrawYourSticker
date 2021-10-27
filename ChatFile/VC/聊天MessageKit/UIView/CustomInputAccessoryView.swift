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
    func inputChanged()
    func presentAdd(isSelected:Bool)
    func presentCamera()
    func presentAlbum()
}

class CustomInputAccessoryView: UIView {

    var delegate:CustomInputAccessoryViewDelegate?
    
    let messageInputTextView: UITextView = {
        let tv = UITextView()
        //tv.backgroundColor = .lightGray
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.isScrollEnabled = false
        tv.textColor = .darkGray
        tv.backgroundColor = .clear
        return tv
    }()
    
    let uiview: UIView = {
        let vw = UIView()
        vw.backgroundColor = #colorLiteral(red: 0.897361517, green: 0.8974907994, blue: 0.9007901549, alpha: 1)
        vw.layer.cornerRadius = 20
        return vw
    }()
    
    let btnEmoji: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "icons8-anime-emoji-100 (1)"), for: .normal)
        return btn
    }()
    
    private lazy var btnAdd: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "plus"), for: .normal)
        btn.addTarget(self, action: #selector(handleAdd), for: .touchUpInside)
        btn.tintColor = .black
        return btn
    }()
    
    private lazy var btnAddCamera: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "icons8-camera-96"), for: .normal)
        btn.addTarget(self, action: #selector(handleAddCamera), for: .touchUpInside)
        btn.tintColor = .black
        return btn
    }()
    
    private lazy var btnAddLibraryPhoto: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "icons8-picture-144 (1)"), for: .normal)
        btn.addTarget(self, action: #selector(handleAddAlbum), for: .touchUpInside)
        btn.tintColor = .black
        return btn
    }()
    
    private lazy var btnSend: UIButton = {
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
    
    required init?(coder: NSCoder) {
        fatalError("inti has not been implement")
    }
    
    override var intrinsicContentSize: CGSize {
        return .zero
    }
   
    // MARK: - init layout ， 初始化Layout
    override init(frame: CGRect) {
        super.init(frame: frame)
        autoresizingMask = .flexibleHeight
        layer.shadowOpacity = 0.25
        layer.shadowOffset = .init(width: 0, height: -8)
        layer.shadowColor = UIColor.lightGray.cgColor
        backgroundColor = .white
        
        addSubview(btnAdd) // 新增
        btnAdd.anchor(top:topAnchor,left: leftAnchor,paddingTop: 15,paddingLeft: 12)
        
        btnAdd.setDimensions(height: 30, width: 30)
        //btnAdd.centerY(inView: self)
        
        addSubview(btnAddCamera) // 拍照
        btnAddCamera.anchor(top:topAnchor,left: btnAdd.rightAnchor,paddingTop: 15,paddingLeft: 12)
        btnAddCamera.setDimensions(height: 30, width: 30)
        
        addSubview(btnAddLibraryPhoto) // 相簿
        btnAddLibraryPhoto.anchor(top:topAnchor,left: btnAddCamera.rightAnchor,paddingTop: 15,paddingLeft: 12)
        btnAddLibraryPhoto.setDimensions(height: 30, width: 30)
        
        addSubview(btnSend) // 送出訊息button
        btnSend.anchor(top:topAnchor,right: rightAnchor,paddingTop: 15,paddingRight: 12)
        btnSend.setDimensions(height: 30, width: 30)
        
        addSubview(uiview) // 聊天輸入框背景
        uiview.anchor(top:topAnchor, left: btnAddLibraryPhoto.rightAnchor,bottom: safeAreaLayoutGuide.bottomAnchor,
                                    right: btnSend.leftAnchor, paddingTop:10, paddingLeft: 8,paddingBottom: 12, paddingRight: 8)
       // uiview.setHeight(height:  40)
        
        addSubview(btnEmoji)  // 聊天輸入框 換鍵盤按鈕
        btnEmoji.addTarget(self, action: #selector(changeKeyboardType(_:)), for: .touchUpInside)
        btnEmoji.anchor(top:topAnchor,
                        right: btnSend.leftAnchor, paddingTop:18, paddingRight: 20)
        btnEmoji.setDimensions(height: 24, width: 24)
        
        addSubview(messageInputTextView) // 聊天輸入框
        messageInputTextView.anchor(top:topAnchor, left: btnAddLibraryPhoto.rightAnchor, bottom: safeAreaLayoutGuide.bottomAnchor,
                                    right: btnEmoji.leftAnchor, paddingTop:12, paddingLeft: 16,paddingBottom: 12, paddingRight: 6)
       // messageInputTextView.setHeight(height:  50)
        
        addSubview(placeholderLabel) // 聊天輸入框placeholder
        placeholderLabel.anchor(top:topAnchor, left: btnAddLibraryPhoto.rightAnchor, paddingTop:10, paddingLeft: 22)
        placeholderLabel.setHeight(height: 40)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextInputChange), name: UITextView.textDidChangeNotification, object: nil)
        
    }
    @objc func changeKeyboardType(_ sender:UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected == true {
            btnEmoji.setImage(UIImage(named: "icons8-keyboard-96"), for: .normal)
            messageInputTextView.resignFirstResponder()
            let keyboardSettings = KeyboardSettings(bottomType: .categories)
            let emojiView = EmojiView(keyboardSettings: keyboardSettings)
            emojiView.translatesAutoresizingMaskIntoConstraints = false
            emojiView.delegate = self
            messageInputTextView.inputView = emojiView
            messageInputTextView.becomeFirstResponder()
        } else {
            btnEmoji.setImage(UIImage(named: "icons8-anime-emoji-100 (1)"), for: .normal)
            
            messageInputTextView.resignFirstResponder()
            messageInputTextView.inputView = nil
            messageInputTextView.becomeFirstResponder()
        }
    }
    
    // MARK: - 新增媒體
    @objc func handleAdd(_ sender:UIButton) {
        sender.isSelected = !sender.isSelected
        delegate?.presentAdd(isSelected:sender.isSelected)
    }
    
    // MARK: - 新增相簿
    @objc func handleAddCamera() {
        delegate?.presentCamera()
    }
    
    // MARK: - 新增拍照
    @objc func handleAddAlbum() {
        delegate?.presentAlbum()
    }
    
    // MARK: - 清除TextFiend內容
    func clearSendMessage() {
        messageInputTextView.text = nil
        placeholderLabel.isHidden = false
    }
    
    // MARK: - User寫文字時，TextFiend內容改變
    @objc func handleTextInputChange() {
        delegate?.inputChanged()
        
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
    
    // MARK: - 點擊送出訊息Button
    @objc func handleSendMessage() {
        if self.messageInputTextView.text.isEmpty == false {
            btnSend.setImage(UIImage(named: "icons8-send-64"), for: .normal)
            btnSend.tintColor = #colorLiteral(red: 0.768627451, green: 0.768627451, blue: 0.768627451, alpha: 1)
            btnSend.isEnabled = false
            guard let message = messageInputTextView.text else { return }
            delegate?.inputView(self,wantsToSend: message)
        } else {
            btnSend.isEnabled = true
            btnSend.tintColor = .systemBlue
            btnSend.setImage(UIImage(named: "icons8-send-234"), for: .normal)
        }
        placeholderLabel.isHidden = !self.messageInputTextView.text.isEmpty
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
