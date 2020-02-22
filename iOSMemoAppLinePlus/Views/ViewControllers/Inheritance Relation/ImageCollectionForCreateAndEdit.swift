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

@objc protocol ImageCollectionForCreateAndEditDelegate: class {
    func collectionViewHasImageMoreThanOne(hasImage: Bool)
}


class ImageCollectionForCreateAndEdit: ImageCollectionForDetail {

    // MARK: Properties
    
    weak var delegate: ImageCollectionForCreateAndEditDelegate?
    
    let imagePicker = UIImagePickerController()
    
    let addImagesButton = CustomButton(backgroundColor: MyColors.KeyColor,
                                       title: ButtonNames.addImage)
    
    var imagesToAdd: [MyImageTypes]! {
        didSet {
            checkSelfHaveChildrenVC(on: self)
            if imagesToAdd?.isEmpty ?? true {
                delegate?.collectionViewHasImageMoreThanOne(hasImage: false)
                self.showEmptyStateView(with: TextMessages.attachPicture,
                                        in: self.view,
                                        imageName: EmptyStateViewImageName.offerImage,
                                        superViewType: .createNew)
            } else {
                delegate?.collectionViewHasImageMoreThanOne(hasImage: true)
                guard let createVC = self.parent as? CreateNewMemoViewController else {return}
                guard let images = self.imagesToAdd else {return}
                createVC.addedImages = images
            }
        }
    }
    
    // MARK: Lifecycle
    
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
    
    deinit {
        print("Collection for Create&Edit Deinit")
    }
    
    // MARK: - Setup
    
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
            checkSelfHaveChildrenVC(on: self)
            self.showEmptyStateView(with: TextMessages.attachPicture,
                                    in: self.view,
                                    imageName: EmptyStateViewImageName.offerImage,
                                    superViewType: .createNew)
        } else {
            collectionView.reloadData()
        }
    }
    
    func setupLongPressGestureRecognizer() {
        let gesture = UILongPressGestureRecognizer(target: self,
                                                   action: #selector(reorderCollectionViewItem(_:)))
        gesture.minimumPressDuration = 0.5
        collectionView.addGestureRecognizer(gesture)
    }
    
    // MARK: - Action Handle
    
    func presentActionSheetToSelectImageSource() {
        let alert = UIAlertController(title: Titles.select, message: "", preferredStyle: .actionSheet)
        
        let takePhoto = UIAlertAction(title: ButtonNames.takePicture, style: .default) { (_) in
            guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
            self.imagePicker.sourceType = .camera
            self.imagePicker.videoQuality = .typeHigh
            self.present(self.imagePicker, animated: true)
        }
        
        let album = UIAlertAction(title: ButtonNames.fromAlbum, style: .default) { (_) in
            self.imagePicker.sourceType = .savedPhotosAlbum
            self.present(self.imagePicker, animated: true)
        }
        
        let url = UIAlertAction(title: ButtonNames.fromUrl, style: .default) { (_) in
            let loadImageVC = LoadImageFromURLViewController()
            loadImageVC.delegate = self
            loadImageVC.modalPresentationStyle = .fullScreen
            self.present(loadImageVC, animated: true)
        }
        
        let cancel = UIAlertAction(title: ButtonNames.cancel, style: .cancel)
        
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
    
    // MARK: - Overridden and Just UICollectionViewDataSource Method
    
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return imagesToAdd?.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCellForCollection.identifier,
                                                      for: indexPath) as! ImageCellForCollection
        cell.delegate = self
        guard let image = imagesToAdd?[indexPath.item] else {
            cell.imageView.image = PlaceHolderImages.defaultImage
            return cell
        }
        checkImageSourceTypeAndSetValueOnCell(checkObject: image, for: cell)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        moveItemAt sourceIndexPath: IndexPath,
                        to destinationIndexPath: IndexPath) {
        guard sourceIndexPath != destinationIndexPath else { return }
        let source = sourceIndexPath.item
        let destination = destinationIndexPath.item
        
        let element = imagesToAdd.remove(at: source)
        imagesToAdd.insert(element, at: destination)
    }
    
    // MARK: - Overridden UICollectionViewDelegate Method
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("select in createVC")
        
    }
}


// MARK: - UIImagePickerControllerDelegate

extension ImageCollectionForCreateAndEdit: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let mediaType = info[.mediaType] as! NSString

        if UTTypeEqual(mediaType, kUTTypeImage) {
            let originalImage = info[.originalImage] as! UIImage
            let editedImage = info[.editedImage] as? UIImage
            let selectedImage = editedImage ?? originalImage
            
            if imagesToAdd == nil {
                let initialArray = [MyImageTypes.image(selectedImage)]
                self.imagesToAdd = initialArray
            } else {
                self.imagesToAdd.append(MyImageTypes.image(selectedImage))
            }
            
            self.collectionView.reloadData()
        }
        picker.dismiss(animated: true)
    }
}

// MARK: - ImageCellForCollectionDelegate

extension ImageCollectionForCreateAndEdit: ImageCellForCollectionDelegate {
    
    func didTapRemoveButtonOnImage(in cell: ImageCellForCollection) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
            self.imagesToAdd.remove(at: indexPath.row)
            self.collectionView.deleteItems(at: [indexPath])
            self.checkImagesArrayEmpty()
            self.collectionView.reloadData()
    }
}

// MARK: - LoadImageFromURLViewControllerDelegate

extension ImageCollectionForCreateAndEdit: LoadImageFromURLViewControllerDelegate {
    func passUrlString(urlString: MyImageTypes) {
        if self.imagesToAdd == nil {
            self.imagesToAdd = [urlString]
        } else {
            self.imagesToAdd.append(urlString)
        }
    }
}
