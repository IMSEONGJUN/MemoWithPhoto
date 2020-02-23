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
        if self.memo.images?.convertToMyImageTypeArray()?.isEmpty ?? true {
            checkSelfHaveChildrenVC(on: self)
            showEmptyStateViewOnDetailVC()
        }
    }
    
    func showEmptyStateViewOnDetailVC() {
        showEmptyStateView(with: TextMessages.noImages,
                           in: self.view,
                           imageName: EmptyStateViewImageName.noPicture,
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
        collectionView.register(ImageCellForCollection.self,
                                forCellWithReuseIdentifier: ImageCellForCollection.identifier)
    }
    
    private func configureFlowlayout() {
        let collectionViewSideInset: CGFloat = 20
        let itemsInLine: CGFloat = 2
        
        layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        let availableWidth: CGFloat = view.frame.width - collectionViewSideInset
        let itemSizeWidth = availableWidth / itemsInLine
        layout.itemSize = CGSize(width: itemSizeWidth, height: itemSizeWidth)
    }
    
    private func setConstraints() {
        collectionView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(0.8)
        }
    }
    
    func checkImageSourceTypeAndSetValueOnCell(checkObject: MyImageTypes,
                                               for cell: ImageCellForCollection) {
        switch checkObject {
        case .image(let image):
            cell.imageView.image = image
        case .urlString(let urlString):
            cell.imageView.image = PlaceHolderImages.loading
            NetworkManager.shared.downloadImage(from: urlString) { (result) in
                DispatchQueue.main.async {
                    switch result {
                    case .failure(_):
                        cell.imageView.image = PlaceHolderImages.imageLoadFail
                    case .success(let image):
                        cell.imageView.image = image
                    }
                }
            }
        }
    }
    
    deinit{
        print("Collection for Detail Deinit")
    }
}

extension ImageCollectionForDetail: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memo.images?.convertToMyImageTypeArray()?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCellForCollection.identifier,
                                                      for: indexPath) as! ImageCellForCollection
        
        
        guard let images = memo.images?.convertToMyImageTypeArray() else {
            cell.imageView.image = PlaceHolderImages.defaultImage
            return cell
        }
      
        cell.removeButton.isHidden = true
        let image = images[indexPath.item]
        checkImageSourceTypeAndSetValueOnCell(checkObject: image, for: cell)
        return cell
    }
}

extension ImageCollectionForDetail: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("didselect in detail")
        // TODO: 선택시 디테일 뷰 띄우기
    }
}
