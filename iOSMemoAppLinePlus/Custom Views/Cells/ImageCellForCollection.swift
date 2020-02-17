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
    
    weak var delegate: ImageCellForCollectionDelegate?
    
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
        imageView.addSubview(removeButton)
        imageView.isUserInteractionEnabled = true
        
        
        removeButton.setImage(UIImage(named: "remove"), for: .normal)
        removeButton.addTarget(self, action: #selector(didTapRemoveButton), for: .touchUpInside)
        removeButton.isEnabled = true
        
    }
    
    @objc private func didTapRemoveButton() {
        print("removeButton Tap!!")
        delegate?.didTapRemoveButtonOnImage(in: self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        imageView.frame = contentView.bounds
        let removeButtonSize:CGFloat = imageView.frame.size.width * 0.2
        removeButton.frame = CGRect(x: imageView.frame.size.width - removeButtonSize, y: 0, width: removeButtonSize, height: removeButtonSize)
//        imageView.bringSubviewToFront(removeButton)
    }
}
