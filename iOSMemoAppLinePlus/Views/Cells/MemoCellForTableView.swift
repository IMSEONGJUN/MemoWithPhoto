//
//  MemoCell.swift
//  iOSMemoAppLinePlus
//
//  Created by SEONGJUN on 2020/02/13.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import UIKit
import SnapKit

class MemoCell: UITableViewCell {

    static let identifier = "MemoCell"
    
    private let thumnailImageView = UIImageView()
    private let titleLabel = TitleLabel()
    private let somePartsOfMemoLabel = BodyLabel()
    private let dateLabel = UILabel()
    private let nextImage = UIImageView(image: PlaceHolderImages.next)
    
    private var memoData: Memo! {
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
    
    private func reConfigureCell() {
        if let retrievedImageArray = self.memoData.images?.imageArray(), retrievedImageArray.count != 0 {
            switch retrievedImageArray.first {
            case .image(let image):
                self.thumnailImageView.image = image
            case .urlString(let urlString):
                getImageFromURL(urlString: urlString)
            default:
                break
            }
        } else {
            self.thumnailImageView.image = PlaceHolderImages.defaultImage
        }
        
        self.titleLabel.text = self.memoData.title
        self.somePartsOfMemoLabel.text = self.memoData.content
        self.dateLabel.text = formatter.string(for: self.memoData.recentlyEditedDate)
    }
    
    private func getImageFromURL(urlString: String) {
        self.thumnailImageView.image = PlaceHolderImages.loading
        NetworkManager.shared.downLoadImage(from: urlString) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let image):
                    self.thumnailImageView.image = image
                case .failure(_):
                    self.thumnailImageView.image = PlaceHolderImages.noImage
                }
            }
        }
    }
    
    private func setupUI() {
        [thumnailImageView, titleLabel, somePartsOfMemoLabel, dateLabel, nextImage].forEach {contentView.addSubview($0)}

        contentView.backgroundColor = MyColors.content
        thumnailImageView.layer.cornerRadius = 12
        thumnailImageView.clipsToBounds = true
        
        somePartsOfMemoLabel.numberOfLines = 2
        somePartsOfMemoLabel.lineBreakMode = .byTruncatingTail
        
        dateLabel.font = UIFont.systemFont(ofSize: 12)
        nextImage.backgroundColor = MyColors.content
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
        
        nextImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nextImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nextImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            nextImage.widthAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.1),
            nextImage.heightAnchor.constraint(equalTo: nextImage.widthAnchor)
        ])
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dateLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: nextImage.leadingAnchor, constant: -15),
        ])
        
        
    }
    
    func set(memo: Memo) {
        self.memoData = memo
    }
}
