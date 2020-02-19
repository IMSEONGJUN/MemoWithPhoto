//
//  EmptyStateView.swift
//  iOSMemoAppLinePlus
//
//  Created by SEONGJUN on 2020/02/15.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import UIKit

//protocol EmptyStateViewDelegate: class {
//    func presentImageSourceSelection(view: EmptyStateView) // 여기부터
//}

class EmptyStateView: UIViewController {
    
    let messageLabel = NotiLabel(textAlignment: .center, fontSize: 18)
    let logoImageView = UIImageView()
    let createNewButton = UIButton()
    
    var isOnTheCreateVC = false
    
//    weak var delegate: EmptyStateViewDelegate?
    
    var token: NSObjectProtocol?
    
    var padding:CGFloat = 5
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        configure()
        setConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        view.addSubview(createNewButton)
        
        messageLabel.numberOfLines = 2
        messageLabel.backgroundColor = .systemPurple
        messageLabel.textColor = .white
        
        
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        createNewButton.setImage(UIImage(named: "plus"), for: .normal)
        createNewButton.addTarget(self, action: #selector(didTapCreateNewButton), for: .touchUpInside)
        createNewButton.translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -10),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.2),
            logoImageView.heightAnchor.constraint(equalTo: logoImageView.widthAnchor),
            
            createNewButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            createNewButton.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: padding),
            createNewButton.widthAnchor.constraint(equalTo: logoImageView.widthAnchor, multiplier: 0.4),
            createNewButton.heightAnchor.constraint(equalTo: createNewButton.widthAnchor),
            
            messageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            messageLabel.bottomAnchor.constraint(equalTo: logoImageView.topAnchor, constant: -padding)
        ])
    }
    
    private func setNotiObserver() {
        if isOnTheCreateVC {
            token = NotificationCenter.default.addObserver(forName: EmptyStateView.didTapNewImageAddedButton,
                                                           object: nil,
                                                           queue: OperationQueue.main,
                                                           using: { (noti) in
                                                            if let vc = self.parent as? ImageCollectionVCInCreateVC {
                                                                
//                                                                self.view.removeFromSuperview()
                                                                vc.presentActionSheetToSelectImageSource()
                                                            }
            })
        } else {
            token = NotificationCenter.default.addObserver(forName: EmptyStateView.didTapNewMemoCreatedButton,
                                                           object: nil,
                                                           queue: OperationQueue.main,
                                                           using: { (noti) in
                                                            if let vc = self.parent as? MemoListViewController {
                                                                vc.didTapAddNewMemoButton()
                                                            }
            })
        }
    }
    
    @objc private func didTapCreateNewButton() {
        if isOnTheCreateVC {
            print("add image")
            NotificationCenter.default.post(name: EmptyStateView.didTapNewImageAddedButton, object: nil)
        } else {
            print("add memo")
            NotificationCenter.default.post(name: EmptyStateView.didTapNewMemoCreatedButton, object: nil)
        }
    }
    
    deinit{
        if let token = token {
            NotificationCenter.default.removeObserver(token)
        }
    }
}

extension EmptyStateView {
    static let didTapNewMemoCreatedButton = Notification.Name(rawValue: "didTapCreateNewMemoButton")
    static let didTapNewImageAddedButton = Notification.Name(rawValue: "didTapNewImageAddedButton")
}
