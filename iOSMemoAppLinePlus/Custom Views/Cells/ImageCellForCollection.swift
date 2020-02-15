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
    
    let imageView = UIImageView()
    let removeButton = UIButton()
    let buttonContainer = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        imageView.contentMode = .scaleAspectFit
        backgroundView = imageView
        buttonContainer.addSubview(removeButton)
        buttonContainer.alpha = 0.5
        removeButton.setImage(UIImage(named: "remove"), for: .normal)
        imageView.addSubview(removeButton)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
        let removeButtonSize:CGFloat = imageView.frame.width * 0.2
        removeButton.frame = CGRect(x: imageView.frame.width - removeButtonSize, y: 0, width: removeButtonSize, height: removeButtonSize)
        buttonContainer.frame = removeButton.frame
        imageView.bringSubviewToFront(removeButton)
    }
}
