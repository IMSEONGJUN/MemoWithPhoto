//
//  ImageCellForCollection.swift
//  iOSMemoAppLinePlus
//
//  Created by SEONGJUN on 2020/02/14.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import UIKit
import SnapKit

protocol ImageCellForCollectionDelegate: AnyObject {
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
    
    deinit {
        print("deinit ImageCellForCollection")
    }
    
    // MARK: - Setup
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let removeButtonSizeRatioToImageView: CGFloat = 0.2
        let cellInset: CGFloat = 10
        
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: cellInset, left: cellInset, bottom: cellInset, right: cellInset))
        imageView.frame = contentView.bounds // imageview는 contentView의 서브뷰이므로 bounds가 아닌 frame으로 주면 위에서 contentView.frame의 좌표값이 변했기 때문에 contentView안에서 imageView의 좌표가 superview 기준으로 10,10만큼 이동되어 있다. bounds는 항상 좌표가 (0,0)이므로 imageView가 contentView안에 딱맞춰진다.
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
