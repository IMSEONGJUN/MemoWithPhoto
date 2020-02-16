//
//  ImageCellForCollection.swift
//  iOSMemoAppLinePlus
//
//  Created by SEONGJUN on 2020/02/14.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import UIKit

protocol ImageCellForCollectionDelegate: class {
    func didTapRemoveButtonOnImage(in cell:ImageCellForCollection)
}


class ImageCellForCollection: UICollectionViewCell {
    
    static let identifier = "ImageCellForCollection"
    
    var isImageFromURL = false
    let imageView = UIImageView()
    let removeButton = UIButton()
    let buttonContainer = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        imageView.contentMode = .scaleAspectFill
        contentView.addSubview(imageView)
        imageView.clipsToBounds = true
        imageView.addSubview(buttonContainer)
        buttonContainer.addSubview(removeButton)
        buttonContainer.backgroundColor = .green
        buttonContainer.alpha = 0.5
        removeButton.setImage(UIImage(named: "remove"), for: .normal)
        imageView.addSubview(removeButton)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        imageView.frame = contentView.bounds
        let removeButtonSize:CGFloat = imageView.frame.size.width * 0.2
        buttonContainer.frame = CGRect(x: imageView.frame.size.width - removeButtonSize, y: 0, width: removeButtonSize, height: removeButtonSize)
        removeButton.frame = buttonContainer.frame
        imageView.bringSubviewToFront(removeButton)
    }
}
