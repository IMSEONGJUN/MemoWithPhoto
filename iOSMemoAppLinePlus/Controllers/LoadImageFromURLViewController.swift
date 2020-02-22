//
//  LoadImageFromURLViewController.swift
//  iOSMemoAppLinePlus
//
//  Created by SEONGJUN on 2020/02/18.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import UIKit
import SnapKit

protocol LoadImageFromURLViewControllerDelegate: class {
    func passUrlString(urlString: MyImageTypes)
}


class LoadImageFromURLViewController: UIViewController {

    let urlTextField = UITextField()
    private var tempURLStorage = ""
    
    weak var delegate: LoadImageFromURLViewControllerDelegate!
    
    let loadButton = CustomButton(backgroundColor: MyColors.brown, title: ButtonNames.loadPicture)
    let deleteImageButton = CustomButton(backgroundColor: MyColors.brown, title: ButtonNames.deletePicture)
    let tempImageView = UIImageView()
    
    let cancelButton = CustomButton(backgroundColor: .systemPurple, title: ButtonNames.cancel)
    let useImageButton = CustomButton(backgroundColor: MyColors.KeyColor, title: ButtonNames.usePicture)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configure()
        setConstraints()
        createDismissKeyboardTapGesture()
    }
    
    private func configure() {
        [urlTextField, loadButton, deleteImageButton, tempImageView, cancelButton, useImageButton].forEach({
            view.addSubview($0)
        })
        [loadButton, deleteImageButton, cancelButton, useImageButton].forEach({
            $0.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
        })
        
        tempImageView.contentMode = .scaleAspectFit
        tempImageView.backgroundColor = MyColors.content

        urlTextField.keyboardType = .URL
        urlTextField.placeholder = ButtonNames.urlInput
        urlTextField.clearsOnBeginEditing = true
        urlTextField.clearButtonMode = .always
        urlTextField.borderStyle = .roundedRect
    }
    
    private func setConstraints() {
        let padding: CGFloat = 30
        let buttonHeight: CGFloat = 50
        let imageViewSizeRatioToSuperView: CGFloat = 0.7
        let buttonsWidthRatioToImageView: CGFloat = 0.4
        
        urlTextField.snp.makeConstraints {
            $0.top.equalToSuperview().offset(topbarHeight + 30)
            $0.leading.trailing.equalToSuperview().inset(50)
            $0.height.equalToSuperview().multipliedBy(0.06)
        }
        tempImageView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.width.height.equalTo(view.snp.width).multipliedBy(imageViewSizeRatioToSuperView)
        }
        loadButton.snp.makeConstraints {
            $0.leading.equalTo(tempImageView.snp.leading)
            $0.top.equalTo(urlTextField.snp.bottom).offset(padding)
            $0.width.equalTo(tempImageView.snp.width).multipliedBy(buttonsWidthRatioToImageView)
            $0.height.equalTo(buttonHeight)
        }
        deleteImageButton.snp.makeConstraints {
            $0.top.bottom.width.equalTo(loadButton)
            $0.trailing.equalTo(tempImageView.snp.trailing)
            $0.height.equalTo(buttonHeight)
        }
        cancelButton.snp.makeConstraints {
            $0.top.equalTo(tempImageView.snp.bottom).offset(padding)
            $0.leading.equalTo(tempImageView.snp.leading)
            $0.width.equalTo(tempImageView.snp.width).multipliedBy(buttonsWidthRatioToImageView)
            $0.height.equalTo(buttonHeight)
        }
        useImageButton.snp.makeConstraints {
            $0.top.equalTo(tempImageView.snp.bottom).offset(padding)
            $0.trailing.equalTo(tempImageView.snp.trailing)
            $0.width.equalTo(tempImageView.snp.width).multipliedBy(buttonsWidthRatioToImageView)
            $0.height.equalTo(buttonHeight)
        }
    }
    
    @objc private func didTapButton(_ sender: UIButton) {
        switch sender {
        case loadButton:
            loadImage()
        case deleteImageButton:
            self.tempImageView.image = nil
        case cancelButton:
            self.dismiss(animated: true, completion: nil)
        case useImageButton:
            passDataToParentVC()
        default:
            break
        }
    }

    private func loadImage() {
        tempURLStorage = urlTextField.text ?? ""
        guard tempURLStorage.count > 0 else {
            presentAlertOnMainThread(title: Titles.info, message: TextMessages.inputUrl)
            return
        }
        showLoadingView()
        NetworkManager.shared.downloadImage(from: tempURLStorage) { [weak self] result in
            guard let self = self else { return }
            self.dismissLoadingView()
            
            switch result {
            case .success(let image):
                DispatchQueue.main.async {
                    self.tempImageView.image = image
                }
            case .failure(let error):
                self.presentAlertOnMainThread(title: Titles.error, message: error.rawValue)
                DispatchQueue.main.async {
                    self.tempImageView.image = PlaceHolderImages.imageLoadFail
                }
            }
        }
    }
    
    private func passDataToParentVC() {
        guard tempImageView.image != nil else { return }
        guard tempImageView.image != PlaceHolderImages.imageLoadFail else {
            presentAlertOnMainThread(title: Titles.error, message: TextMessages.failedToLoad)
            return
        }
        
        let urlString = MyImageTypes.urlString(tempURLStorage)
        self.delegate.passUrlString(urlString: urlString)
        self.dismiss(animated: true)
    }
    
    private func createDismissKeyboardTapGesture() {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        view.addGestureRecognizer(tap)
    }
    
    deinit {
        print("LoadImageFromUrlVC Deinit")
    }
}
