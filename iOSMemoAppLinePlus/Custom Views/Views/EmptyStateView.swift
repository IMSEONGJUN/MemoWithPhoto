//
//  EmptyStateView.swift
//  iOSMemoAppLinePlus
//
//  Created by SEONGJUN on 2020/02/15.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import UIKit

class NotiLabel: TitleLabel {
    override var intrinsicContentSize: CGSize {
        get {
            let originalIntrinsicContentSize = super.intrinsicContentSize
            let height = originalIntrinsicContentSize.height + 15
            layer.cornerRadius = height / 2
            layer.masksToBounds = true
            return CGSize(width: originalIntrinsicContentSize.width + 20, height: height)
        }
    }
}



class EmptyStateView: UIViewController {

    let messageLabel = NotiLabel(textAlignment: .center, fontSize: 18)
    let logoImageView = UIImageView()
    let addNewMemoButton = UIButton()
    var token: NSObjectProtocol?
    
    var padding:CGFloat = 30
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        configure()
        setConstraints()
        setNotiObserver()
    }
    
    init(message: String, imageName: String) {
        super.init(nibName: nil, bundle: nil)
        messageLabel.text = message
        logoImageView.image = UIImage(named: imageName)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        view.addSubview(messageLabel)
        view.addSubview(logoImageView)
        view.addSubview(addNewMemoButton)
        
        messageLabel.numberOfLines = 2
        messageLabel.backgroundColor = .systemPurple
        messageLabel.textColor = .white
        
        
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        addNewMemoButton.setImage(UIImage(named: "plus"), for: .normal)
        addNewMemoButton.addTarget(self, action: #selector(didTapCreateNewMemoButton), for: .touchUpInside)
        addNewMemoButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 10),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.3),
            logoImageView.heightAnchor.constraint(equalTo: logoImageView.widthAnchor),
            
            addNewMemoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addNewMemoButton.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: padding),
            addNewMemoButton.widthAnchor.constraint(equalTo: logoImageView.widthAnchor, multiplier: 0.6),
            addNewMemoButton.heightAnchor.constraint(equalTo: addNewMemoButton.widthAnchor),
            
            messageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            messageLabel.bottomAnchor.constraint(equalTo: logoImageView.topAnchor, constant: -padding)
        ])
    }
    
    private func setNotiObserver() {
        token = NotificationCenter.default.addObserver(forName: EmptyStateView.newMemoCreated, object: nil,
                                                       queue: OperationQueue.main,
                                                       using: { (noti) in
            if let vc = self.parent as? MemoListViewController {
                vc.didTapAddNewMemoButton()
            }
        })
    }
    
    @objc private func didTapCreateNewMemoButton() {
        NotificationCenter.default.post(name: EmptyStateView.newMemoCreated, object: nil)
    }
    
    deinit{
        if let token = token {
            NotificationCenter.default.removeObserver(token)
        }
    }
}

extension EmptyStateView {
    static let newMemoCreated = Notification.Name(rawValue: "didTapCreateNewMemoButton")
}
