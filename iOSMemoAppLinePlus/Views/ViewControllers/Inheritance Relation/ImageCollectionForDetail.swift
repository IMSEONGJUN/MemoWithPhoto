//
//  ImageCollectionViewController.swift
//  iOSMemoAppLinePlus
//
//  Created by SEONGJUN on 2020/02/13.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import UIKit
import SnapKit

class ImageCollectionForDetail: UIViewController {
    
    var layout: UICollectionViewFlowLayout!
    var collectionView: UICollectionView!
    
    var memo: Memo!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        fetchMemo()
    }
    
    func fetchMemo() {
        guard let detailVC = self.parent as? MemoDetailViewController else {
            return
        }
        self.memo = detailVC.memo
        if self.memo.images?.imageArray()?.isEmpty ?? true {
            if self.children.count > 0{
                self.children.forEach({ $0.willMove(toParent: nil); $0.view.removeFromSuperview(); $0.removeFromParent() })
            }
            showEmptyStateViewOnDetailVC()
        }
    }
    
    func showEmptyStateViewOnDetailVC() {
        showEmptyStateView(with: "등록된 이미지가 없습니다", in: self.view, imageName: EmptyStateViewImageName.noPicture,
        superViewType: .detail) 
    }
    
    private func configureCollectionView() {
        
        configureFlowlayout()
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        view.addSubview(collectionView)
        
        setConstraints()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .white
        collectionView.allowsSelection = true
        collectionView.register(ImageCellForCollection.self, forCellWithReuseIdentifier: ImageCellForCollection.identifier)
        
    }
    
    private func configureFlowlayout() {
        layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let availableWidth: CGFloat = view.frame.width - 20
        let itemSizeWidth = availableWidth / 2
        layout.itemSize = CGSize(width: itemSizeWidth, height: itemSizeWidth)
        
    }
    
    private func setConstraints() {
        collectionView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(0.8)
        }
    }
    
    deinit{
        print("Collection for Detail Deinit")
    }

}

extension ImageCollectionForDetail: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memo.images?.imageArray()?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCellForCollection.identifier, for: indexPath) as! ImageCellForCollection
        guard let images = memo.images?.imageArray() else {
            return cell
        }
        switch images[indexPath.item] {
        case .image(let val):
            cell.imageView.image = val
        case .urlString(let val):
            cell.imageView.image = PlaceHolderImages.loading
            NetworkManager.shared.downLoadImage(from: val) { (image) in
                if image == nil {cell.imageView.image = PlaceHolderImages.noImage}
                else {cell.imageView.image = image}
            }
        }
        
        cell.removeButton.isHidden = true
        
        return cell
    }
    
    
}

extension ImageCollectionForDetail: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
           print("didselect in detail")
       }
}
