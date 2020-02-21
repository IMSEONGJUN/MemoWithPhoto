//
//  ImageCollectionVCInCreate.swift
//  iOSMemoAppLinePlus
//
//  Created by SEONGJUN on 2020/02/14.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import UIKit
import SnapKit // Third party Library
import MobileCoreServices


class ImageCollectionForCreateAndEdit: ImageCollectionForDetail {

    
    let imagePicker = UIImagePickerController()
    
    let addImagesButton = CustomButton(backgroundColor: MyColors.KeyColor, title: "이미지 추가하기")
    
    var imagesToAdd: [MyImageTypes]! {
        didSet{
            if imagesToAdd?.isEmpty ?? true {
                if self.children.count > 0{
                    self.children.forEach({ $0.willMove(toParent: nil); $0.view.removeFromSuperview(); $0.removeFromParent() })
                }
                DispatchQueue.main.async {
                    self.showEmptyStateView(with: "사진을 등록하실 수 있습니다.", in: self.view, imageName: EmptyStateViewImageName.offerImage, superViewType: .createNew)
                }
            } else {
                if self.children.count > 0{
                    self.children.forEach({ $0.willMove(toParent: nil); $0.view.removeFromSuperview(); $0.removeFromParent() })
                }
                guard let createVC = self.parent as? CreateNewMemoViewController else {return}
                guard let images = self.imagesToAdd else {return}
                createVC.addedImages = images
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        setupLongPressGestureRecognizer()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        checkImagesArrayEmpty()
    }
    
    private func configure() {
        view.addSubview(addImagesButton)
        addImagesButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(collectionView.snp.bottom).offset(5)
            $0.width.equalToSuperview().multipliedBy(0.5)
        }
        addImagesButton.addTarget(self, action: #selector(didTapImageAddButton), for: .touchUpInside)
    }
    
    private func checkImagesArrayEmpty() {
        if imagesToAdd?.isEmpty ?? true {
            if self.children.count > 0{
                self.children.forEach({ $0.willMove(toParent: nil); $0.view.removeFromSuperview(); $0.removeFromParent() })
            }
            DispatchQueue.main.async {
                self.showEmptyStateView(with: "사진을 등록하실 수 있습니다.", in: self.view, imageName: EmptyStateViewImageName.offerImage,
                superViewType: .createNew)
            }
        } else {
            collectionView.reloadData()
        }
    }
    
    func setupLongPressGestureRecognizer() {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(reorderCollectionViewItem(_:)))
        gesture.minimumPressDuration = 0.5
        collectionView.addGestureRecognizer(gesture)
    }
    
    func presentActionSheetToSelectImageSource() {
        let alert = UIAlertController(title: "선택", message: "", preferredStyle: .actionSheet)
        let takePhoto = UIAlertAction(title: "사진 찍기", style: .default) { (_) in
            guard UIImagePickerController.isSourceTypeAvailable(.camera) else {return}
            
            self.imagePicker.sourceType = .camera
            self.imagePicker.mediaTypes = [kUTTypeImage, kUTTypeMovie] as [String]
            self.imagePicker.videoQuality = .typeHigh
            
            self.present(self.imagePicker, animated: true)
        }
        let album = UIAlertAction(title: "앨범에서 선택", style: .default) { (_) in
            self.imagePicker.sourceType = .savedPhotosAlbum
            self.present(self.imagePicker, animated: true)
        }
        let url = UIAlertAction(title: "URL로 가져오기", style: .default) { (_) in
            let loadImageVC = LoadImageFromURLViewController()
            loadImageVC.delegate = self
            loadImageVC.modalPresentationStyle = .fullScreen
            self.present(loadImageVC, animated: true)
        }
        
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alert.addAction(takePhoto)
        alert.addAction(album)
        alert.addAction(url)
        alert.addAction(cancel)
        self.present(alert, animated: true)
        
    }
    
    @objc func didTapImageAddButton() {
        presentActionSheetToSelectImageSource()
    }
    
    @objc private func reorderCollectionViewItem(_ sender: UILongPressGestureRecognizer) {
        let location = sender.location(in: collectionView)
    
        switch sender.state {
        case .began:
            guard let indexPath = collectionView.indexPathForItem(at: location) else { break }
            collectionView.beginInteractiveMovementForItem(at: indexPath)
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(location)
        case .cancelled:
            collectionView.cancelInteractiveMovement()
        case .ended:
            collectionView.endInteractiveMovement()
        default:
            break
        }
    }
    
    deinit{
        print("Collection for Create&Edit Deinit")
    }
    
    // MARK: - Overridden and Just UICollectionView DataSource Method
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesToAdd?.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCellForCollection.identifier, for: indexPath) as! ImageCellForCollection
        cell.delegate = self
        guard let image = imagesToAdd?[indexPath.item] else {
            cell.imageView.image = PlaceHolderImages.defaultImage
            return cell
        }
        
        switch image {
        case .image(let image):
            cell.imageView.image = image
        case .urlString(let urlString):
            cell.imageView.image = PlaceHolderImages.loading
            NetworkManager.shared.downLoadImage(from: urlString) { (result) in
                switch result {
                case .failure(_):
                    cell.imageView.image = PlaceHolderImages.noImage
                case .success(let image):
                    cell.imageView.image = image
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard sourceIndexPath != destinationIndexPath else {return}
        let source = sourceIndexPath.item
        let destination = destinationIndexPath.item
        
        let element = imagesToAdd.remove(at: source)
        imagesToAdd.insert(element, at: destination)
    }
    
    // MARK: - Overridden UICollectionView Delegate Method
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("select in createVC")
    }
}


// MARK: - UIImagePickerController Delegate Method

extension ImageCollectionForCreateAndEdit: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let mediaType = info[.mediaType] as! NSString

        if UTTypeEqual(mediaType, kUTTypeImage) {
            let originalImage = info[.originalImage] as! UIImage
            let editedImage = info[.editedImage] as? UIImage
            let selectedImage = editedImage ?? originalImage
            if imagesToAdd == nil {
                let initialArray = [MyImageTypes.image(selectedImage)]
                self.imagesToAdd = initialArray
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            } else {
                self.imagesToAdd.append(MyImageTypes.image(selectedImage))
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
            
//            if picker.sourceType == .camera {
//                UIImageWriteToSavedPhotosAlbum(selectedImage, nil, nil, nil)
//            }
        }
        picker.dismiss(animated: true)
    }
}

extension ImageCollectionForCreateAndEdit: ImageCellForCollectionDelegate {
    
    func didTapRemoveButtonOnImage(in cell: ImageCellForCollection) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        collectionView.performBatchUpdates({
            self.imagesToAdd.remove(at: indexPath.row)
            self.collectionView.deleteItems(at: [indexPath])
            self.checkImagesArrayEmpty()
            self.collectionView.reloadData()
        }, completion: nil)
    }
    
}

extension ImageCollectionForCreateAndEdit: LoadImageFromURLViewControllerDelegate {
    func passUrlString(urlString: MyImageTypes) {
        print("pass delegate")
        if self.imagesToAdd == nil {
            self.imagesToAdd = [urlString]
        } else {
            self.imagesToAdd.append(urlString)
        }
    }
    
    
}
