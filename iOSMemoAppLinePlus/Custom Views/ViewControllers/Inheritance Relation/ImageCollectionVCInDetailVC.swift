//
//  ImageCollectionViewController.swift
//  iOSMemoAppLinePlus
//
//  Created by SEONGJUN on 2020/02/13.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import UIKit
import SnapKit

class ImageCollectionVCInDetailVC: UIViewController {

    private enum UI {
        static let itemsInLine: CGFloat = 3
        static let linesOnScreen: CGFloat = 2
        static let itemSpacing: CGFloat = 10.0
        static let lineSpacing: CGFloat = 10.0
        static let edgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10)
    }
    
    var layout: UICollectionViewFlowLayout!
    var collectionView: UICollectionView!
    
    var memo: Memo!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        fetchMemo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchMemo()
    }
    
    func fetchMemo() {
        guard let detailVC = self.parent as? MemoDetailViewController else {
            return
        }
        self.memo = detailVC.memo
        if self.memo.images?.isEmpty ?? true {
            showEmptyStateView(with: "등록된 이미지가 없습니다", in: self.view, imageName: "picture")
        }
        
    }
    
    private func configureCollectionView() {
        
        configureFlowlayout()
        
        collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        
        view.addSubview(collectionView)
        
        setConstraints()
        fitItemsAndLinesOnScreen()
        
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.register(ImageCellForCollection.self, forCellWithReuseIdentifier: ImageCellForCollection.identifier)
        
    }
    
    private func configureFlowlayout() {
        layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = UI.itemSpacing
        layout.minimumLineSpacing = UI.lineSpacing
        layout.sectionInset = UI.edgeInsets
        layout.scrollDirection = .vertical
    }
    
    func fitItemsAndLinesOnScreen() {
        let itemSpacing = UI.itemSpacing * (UI.itemsInLine - 1)
        let lineSpacing = UI.lineSpacing * (UI.linesOnScreen - 1)
        let horizontalInset = UI.edgeInsets.left + UI.edgeInsets.right
        
        let verticalInset = UI.edgeInsets.top + UI.edgeInsets.bottom
//            + view.safeAreaInsets.top //+ 150 더한 숫자만큼 하단 디바이스 범위를 벗어난 item들이 얼마나 보일지가 결정된다
//            + view.safeAreaInsets.bottom // 하단 노치가 있는 경우에 안 더해주면  디바이스 하단까지 item들이 꽉차게 보인다. 더하면 하단 노치에 범위를 벗어난 item들도 살짝 보이게 된다.
        
        let isVertical = layout.scrollDirection == .vertical
        let horizontalSpacing = (isVertical ? itemSpacing : lineSpacing) + horizontalInset
        let verticalSpacing = (isVertical ? lineSpacing : itemSpacing) + verticalInset
        
        let contentWidth = collectionView.frame.width - horizontalSpacing
        let contentHeight = collectionView.frame.height - verticalSpacing
        let width = contentWidth / (isVertical ? UI.itemsInLine : UI.linesOnScreen)
        let height = contentHeight / (isVertical ? UI.linesOnScreen : UI.itemsInLine)
        
        layout.itemSize = CGSize(width: width.rounded(.down), height: height.rounded(.down))
    }
    
    
    
    private func setConstraints() {
        collectionView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(0.7)
        }
    }

}

extension ImageCollectionVCInDetailVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memo.images?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCellForCollection.identifier, for: indexPath) as! ImageCellForCollection
        guard let images = memo.images?.imageArray() else {
            return cell
        }
        cell.imageView.image = images[indexPath.item]
        cell.buttonContainer.isHidden = true
        
        return cell
    }
    
    
}
