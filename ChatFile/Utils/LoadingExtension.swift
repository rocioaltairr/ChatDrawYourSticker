//
//  LoadingExtension.swift
//  ChatFile
//
//  Created by 白白 on 2021/10/26.
//

import UIKit
import NVActivityIndicatorView

public final class LodingActivityIndicatorUtil: NSObject {
    public static let shared = LodingActivityIndicatorUtil()
    
    
    let activityIndicator = NVActivityIndicatorView(
        frame: CGRect(origin: .zero,size: NVActivityIndicatorView.DEFAULT_BLOCKER_SIZE)
    )
    
    override init() {
        self.activityIndicator.color = .systemBlue
        activityIndicator.startAnimating()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func showLoader(view: UIView){
        hideLoader()
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
        }
    }
    
    func hideLoader(){
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
    }
}

public final class UpLodingActivityIndicatorUtil: NSObject {
    public static let shared = UpLodingActivityIndicatorUtil()
    
    
    let activityIndicator = NVActivityIndicatorView(
        frame: CGRect(origin: .zero,size: NVActivityIndicatorView.DEFAULT_BLOCKER_SIZE)
    )
    
    override init() {
        self.activityIndicator.color = .systemBlue
        activityIndicator.startAnimating()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func showLoader(view: UIView){
        hideLoader()
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.widthAnchor.constraint(equalToConstant: 30),
            activityIndicator.heightAnchor.constraint(equalToConstant: 30),
            activityIndicator.topAnchor.constraint(equalTo: view.topAnchor, constant: 85),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])

        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
        }
    }
    
    func hideLoader(){
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
    }
}
