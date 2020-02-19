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
    
    let loadButton = CustomButton(backgroundColor: .darkGray, title: "사진 불러오기")
    let deleteImageButton = CustomButton(backgroundColor: .darkGray, title: "사진 지우기")
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
        
        tempImageView.backgroundColor = .lightGray
        urlTextField.placeholder = "URL 입력"
        urlTextField.clearsOnBeginEditing = true
        urlTextField.clearButtonMode = .always
        urlTextField.borderStyle = .roundedRect
        urlTextField.translatesAutoresizingMaskIntoConstraints = false
        tempImageView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setConstraints(){
        let padding: CGFloat = 30
        
        urlTextField.snp.makeConstraints {
            $0.top.equalToSuperview().offset(topbarHeight + 30)
            $0.leading.trailing.equalToSuperview().inset(50)
            $0.height.equalToSuperview().multipliedBy(0.06)
        }
        tempImageView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.width.height.equalTo(view.snp.width).multipliedBy(0.7)
        }
        loadButton.snp.makeConstraints {
            $0.leading.equalTo(tempImageView.snp.leading)
            $0.top.equalTo(urlTextField.snp.bottom).offset(padding)
            $0.width.equalTo(tempImageView.snp.width).multipliedBy(0.4)
            $0.height.equalTo(50)
        }
        deleteImageButton.snp.makeConstraints {
            $0.top.bottom.width.equalTo(loadButton)
            $0.trailing.equalTo(tempImageView.snp.trailing)
            $0.height.equalTo(50)
        }
        cancelButton.snp.makeConstraints {
            $0.top.equalTo(tempImageView.snp.bottom).offset(padding)
            $0.leading.equalTo(tempImageView.snp.leading)
            $0.width.equalTo(tempImageView.snp.width).multipliedBy(0.4)
            $0.height.equalTo(50)
        }
        useImageButton.snp.makeConstraints {
            $0.top.equalTo(tempImageView.snp.bottom).offset(padding)
            $0.trailing.equalTo(tempImageView.snp.trailing)
            $0.width.equalTo(tempImageView.snp.width).multipliedBy(0.4)
            $0.height.equalTo(50)
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
        
        NetworkManager.shared.downLoadImage(from: tempURLStorage) { (image) in
            if image == nil {
                DispatchQueue.main.async {
                    self.tempImageView.image = PlaceHolderImages.noImage
                }
            }else {
                DispatchQueue.main.async {
                    self.tempImageView.image = image
                }
            }
        }
            
        
    }
    
    private func createDismissKeyboardTapGesture() {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        view.addGestureRecognizer(tap)
    }

}
