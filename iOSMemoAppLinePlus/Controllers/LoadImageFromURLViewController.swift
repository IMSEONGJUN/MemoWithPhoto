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
    var tempURLStorage = ""
    
    weak var delegate: LoadImageFromURLViewControllerDelegate!
    
    let loadButton = CustomButton(backgroundColor: MyColors.brown, title: "사진 불러오기")
    let deleteImageButton = CustomButton(backgroundColor: MyColors.brown, title: "사진 지우기")
    let tempImageView = UIImageView()
    
    let cancelButton = CustomButton(backgroundColor: .systemPurple, title: "취소")
    let useImageButton = CustomButton(backgroundColor: MyColors.KeyColor, title: "사진 사용하기")
    
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
        
        urlTextField.placeholder = "URL 입력"
        urlTextField.clearsOnBeginEditing = true
        urlTextField.clearButtonMode = .always
        urlTextField.borderStyle = .roundedRect
    }
    
    private func setConstraints(){
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
            guard tempImageView.image != PlaceHolderImages.noImage else {
                presentAlertOnMainThread(title: "알림", message: "이미지를 불러오지 못했습니다. \n 다른 url을 입력하세요.")
                return
            }

            let urlString = MyImageTypes.urlString(tempURLStorage)
            self.delegate.passUrlString(urlString: urlString)
            self.dismiss(animated: true)
        default:
            break
        }
    }

    func loadImage() {
        tempURLStorage = urlTextField.text ?? ""
        guard tempURLStorage.count > 0 else {presentAlertOnMainThread(title: "알림", message: "URL을 입력하세요"); return}
        showLoadingView()
        NetworkManager.shared.downLoadImage(from: tempURLStorage) { (image) in
            DispatchQueue.main.async {
                if image == nil{
                    self.tempImageView.image = PlaceHolderImages.noImage
                } else {
                    self.tempImageView.image = image
                }
                self.dismissLoadingView()
            }
        }
            
        
    }
    
    private func createDismissKeyboardTapGesture() {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        view.addGestureRecognizer(tap)
    }
    
    deinit{
        print("LoadImageFromUrlVC Deinit")
    }

}
