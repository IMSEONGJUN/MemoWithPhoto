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
    
    // MARK: Properties
    var layout: UICollectionViewFlowLayout!
    var collectionView: UICollectionView!
    
    var memo: Memo!
    
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        fetchMemo()
        setTapGestureOnCollection()
    }
    init() {
        super.init(nibName: nil, bundle: nil)
        print("Collection for Detail init")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit{
        print("Collection for Detail Deinit")
    }
    
    
    // MARK: - Setup
    
    private func configureCollectionView() {
        
        configureFlowlayout()
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.addSubview(collectionView)
        
        setConstraints()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .white
        collectionView.allowsSelection = true
        collectionView.isUserInteractionEnabled = true
        collectionView.register(ImageCellForCollection.self,
                                forCellWithReuseIdentifier: ImageCellForCollection.identifier)
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
    
    func setTapGestureOnCollection() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.collectionView.addGestureRecognizer(tap)
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
    
    
    // MARK: - Action Handle
    
    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
        if let indexPath = self.collectionView?.indexPathForItem(at: sender.location(in: self.collectionView)) {
            let cell = collectionView.cellForItem(at: indexPath) as! ImageCellForCollection
            guard let selectedImage = cell.imageView.image else { return }
            let imageDetailVC = ImageDetailViewController()
            imageDetailVC.set(image: selectedImage)
            imageDetailVC.modalPresentationStyle = .fullScreen
            present(imageDetailVC, animated: true)
        }
    }
    
    func showEmptyStateViewOnDetailVC() {
        showEmptyStateView(with: TextMessages.noImages,
                           in: self.view,
                           imageName: EmptyStateViewImageName.noPicture,
                           superViewType: .detail)
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
}


// MARK: - UICollectionViewDataSource

extension ImageCollectionForDetail: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memo.images?.convertToMyImageTypeArray()?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCellForCollection.identifier,
                                                      for: indexPath) as! ImageCellForCollection
        
        guard let images = memo.images?.convertToMyImageTypeArray() else {
            cell.imageView.image = PlaceHolderImages.defaultWhenNoImage
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
        print("select cell!!")
    }
}
