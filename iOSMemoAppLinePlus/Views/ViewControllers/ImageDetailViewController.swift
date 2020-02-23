//
//  ImageDetailViewController.swift
//  iOSMemoAppLinePlus
//
//  Created by SEONGJUN on 2020/02/23.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import UIKit
import SnapKit

class ImageDetailViewController: UIViewController {

    let imageView = UIImageView()
    let cancelButton = CustomButton(backgroundColor: MyColors.brown, title: "나가기")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        setConstraints()
        addPinchGestureRecognizer()
    }
    
    private func configure() {
        title = Titles.imageDetail
        view.backgroundColor = .white
        let backButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapBackButton))
        navigationItem.leftBarButtonItem = backButton
        
        view.addSubview(imageView)
        view.addSubview(cancelButton)
        imageView.contentMode = .scaleAspectFit
        cancelButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
    }
    
    private func setConstraints() {
        imageView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.7)
            $0.height.equalTo(imageView.snp.width)
        }
        cancelButton.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.4)
            $0.height.equalTo(imageView.snp.height).multipliedBy(0.2)
        }
    }
    
    private func addPinchGestureRecognizer() {
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        view.addGestureRecognizer(pinchRecognizer)
    }
    
    @objc private func handlePinchGesture(_ sender: UIPinchGestureRecognizer) {
        imageView.transform = imageView.transform.scaledBy(x: sender.scale, y: sender.scale)
        sender.scale = 1.0
    }
    
    func set(image: UIImage) {
        self.imageView.image = image
    }
    
    @objc private func didTapBackButton() {
        dismiss(animated: true)
    }

}
