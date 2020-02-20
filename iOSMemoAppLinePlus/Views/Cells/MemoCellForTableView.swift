//
//  MemoCell.swift
//  iOSMemoAppLinePlus
//
//  Created by SEONGJUN on 2020/02/13.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import UIKit

class MemoCell: UITableViewCell {

    static let identifier = "MemoCell"
    
    private let thumnailImageView = UIImageView()
    private let titleLabel = TitleLabel()
    private let somePartsOfMemoLabel = BodyLabel()
    private let dateLabel = UILabel()
    
    var memoData: Memo! {
        didSet {
            reConfigureCell()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reConfigureCell() {
        if let retrievedImageArray = self.memoData.images?.imageArray(), retrievedImageArray.count != 0 {
            
            switch retrievedImageArray.first {
            case .image(let val):
                self.thumnailImageView.image = val
            case .urlString(let val):
                self.thumnailImageView.image = PlaceHolderImages.loading
                NetworkManager.shared.downLoadImage(from: val) { (image) in
                    if image == nil {
                        DispatchQueue.main.async {
                            self.thumnailImageView.image = PlaceHolderImages.noImage
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.thumnailImageView.image = image
                        }
                    }
                }
            default:
                break
            }
        } else {
            self.thumnailImageView.image = PlaceHolderImages.addedImage
        }
        self.titleLabel.text = self.memoData.title
        self.somePartsOfMemoLabel.text = self.memoData.content
        self.dateLabel.text = formatter.string(for: self.memoData.recentlyModifyDate)
    }
    
    private func setupUI() {
        [thumnailImageView, titleLabel, somePartsOfMemoLabel, dateLabel].forEach {contentView.addSubview($0)}
        accessoryType = .disclosureIndicator
        
        thumnailImageView.layer.cornerRadius = 12
        thumnailImageView.clipsToBounds = true
        
        somePartsOfMemoLabel.numberOfLines = 2
        somePartsOfMemoLabel.lineBreakMode = .byTruncatingTail
        
        dateLabel.font = UIFont.systemFont(ofSize: 12)
    }
    
    private func setConstraints() {
        let padding: CGFloat = 10
        
        let imageViewHeightRatio: CGFloat = 0.8
        
        let titleLabelWidthRatio: CGFloat = 0.4
        let titleLabelHeightRatio: CGFloat = 0.3
        
        let somePartsOfMemoLabelWidthRatio: CGFloat = 0.4
        let somePartsOfMemoLabelHeightRatio: CGFloat = 0.5
        
        thumnailImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            thumnailImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            thumnailImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            thumnailImageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: imageViewHeightRatio),
            thumnailImageView.widthAnchor.constraint(equalTo: thumnailImageView.heightAnchor)
        ])
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: thumnailImageView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: thumnailImageView.trailingAnchor, constant: padding),
            titleLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: titleLabelWidthRatio),
            titleLabel.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: titleLabelHeightRatio),
        ])
        
        somePartsOfMemoLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            somePartsOfMemoLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: padding),
            somePartsOfMemoLabel.leadingAnchor.constraint(equalTo: thumnailImageView.trailingAnchor, constant: padding),
            somePartsOfMemoLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: somePartsOfMemoLabelWidthRatio),
            somePartsOfMemoLabel.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: somePartsOfMemoLabelHeightRatio)
        ])
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dateLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            dateLabel.leadingAnchor.constraint(equalTo: somePartsOfMemoLabel.trailingAnchor, constant: 30),
        ])
    }
    
    func set(memo: Memo) {
        self.memoData = memo
    }
}
