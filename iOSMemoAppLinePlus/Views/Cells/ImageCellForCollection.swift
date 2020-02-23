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
    
    // MARK: Properties
    static let identifier = "ImageCellForCollection"
    
    var isImageFromURL = false
    let imageView = UIImageView()
    let removeButton = UIButton()
    
    weak var delegate: ImageCellForCollectionDelegate?
    
    // MARK: Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Setup
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let removeButtonSizeRatioToImageView: CGFloat = 0.2
        let cellInset: CGFloat = 10
        
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: cellInset, left: cellInset,
                                                                     bottom: cellInset, right: cellInset))
        imageView.frame = contentView.bounds
        let removeButtonSize:CGFloat = imageView.frame.size.width * removeButtonSizeRatioToImageView
        removeButton.frame = CGRect(x: imageView.frame.size.width - removeButtonSize, y: 0, width: removeButtonSize, height: removeButtonSize)
    }
    
    private func configure() {
        contentView.addSubview(imageView)
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.addSubview(removeButton)
        imageView.isUserInteractionEnabled = true
        
        removeButton.setImage(PlaceHolderImages.removeImage, for: .normal)
        removeButton.addTarget(self, action: #selector(didTapRemoveButton), for: .touchUpInside)
        removeButton.isEnabled = true
    }
    
    
    // MARK: - Action Handle
    
    @objc private func didTapRemoveButton() {
        delegate?.didTapRemoveButtonOnImage(in: self)
    }
    
    
}
