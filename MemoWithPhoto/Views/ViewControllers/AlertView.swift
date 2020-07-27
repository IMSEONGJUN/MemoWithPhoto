//
//  AlertViewController.swift
//  iOSMemoAppLinePlus
//
//  Created by SEONGJUN on 2020/02/13.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import UIKit

class AlertViewController: UIViewController {
    
    // MARK: Properties
    private let containerView = UIView()
    private let titleLabel = TitleLabel(textAlignment: .center, fontSize: 20)
    private let messageLabel = BodyLabel(textAlignment: .center)
    private let confirmButton = CustomButton(backgroundColor: .systemGreen, title: "확인")
    
    var alertTitle: String!
    var alertMessage: String!
    var buttonTitle: String!
    
    let padding: CGFloat = 20
    
    
    // MARK: Initializer
    init(title: String, message: String, buttonTitle: String) {
        super.init(nibName: nil, bundle: nil)
        self.alertTitle = title
        self.alertMessage = message
        self.buttonTitle = buttonTitle
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        configureContainerView()
        configureTitleLabel()
        configureMessageLabel()
        configureConfirmButton()
    }
    
    
     // MARK: - Setup
    
    func setupView() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(messageLabel)
        containerView.addSubview(confirmButton)
    }
    
    func configureContainerView() {
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 16
        containerView.layer.borderWidth = 2
        containerView.layer.borderColor = UIColor.white.cgColor
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 280),
            containerView.heightAnchor.constraint(equalToConstant: 220)
        ])
    }
    
    func configureTitleLabel() {
        titleLabel.text = alertTitle
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: padding),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),
            titleLabel.heightAnchor.constraint(equalToConstant: 28)
        ])
    }
    
    func configureMessageLabel() {
        messageLabel.text = alertMessage
        messageLabel.numberOfLines = 4
        
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),
            messageLabel.bottomAnchor.constraint(equalTo: confirmButton.topAnchor, constant: -12)
        ])
    }
    
    func configureConfirmButton() {
        confirmButton.setTitle(buttonTitle, for: .normal)
        confirmButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            confirmButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -padding),
            confirmButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            confirmButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),
            confirmButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    // MARK: - Action Handle
    @objc func dismissVC() {
        dismiss(animated: true)
    }
    
}
