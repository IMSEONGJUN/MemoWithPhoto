//
//  CreateNewMemoViewController.swift
//  iOSMemoAppLinePlus
//
//  Created by SEONGJUN on 2020/02/13.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import UIKit
import SnapKit

class CreateNewMemoViewController: UIViewController {
       
    var titleTextField = UITextField()
    var memoTextView = UITextView()
    let placeholderTextForTextView = "메모 내용을 입력하세요."
    var addedImages = [UIImage]()
    
    let addImageViewContainer = UIView()
    let imageCollectionVC = ImageCollectionVCInCreateVC()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupNavigationBar()
        setConstraints()
        
        
        add(childVC: imageCollectionVC, to: addImageViewContainer)
        createDismissKeyboardTapGesture()
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        [titleTextField, memoTextView, addImageViewContainer].forEach({view.addSubview($0)})
//        titleTextField.backgroundColor = .yellow
//        memoTextView.backgroundColor = .blue
        memoTextView.text = self.placeholderTextForTextView
        memoTextView.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        memoTextView.textColor = .lightGray
        memoTextView.delegate = self
        
        let titleTextFieldPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 6, height: titleTextField.frame.height))
        titleTextField.leftView = titleTextFieldPaddingView
        titleTextField.leftViewMode = .always
        titleTextField.autocorrectionType = .no
        titleTextField.keyboardType = .alphabet
        titleTextField.placeholder = "제목"
        titleTextField.becomeFirstResponder()
        titleTextField.delegate = self
    }
    
    private func setupNavigationBar() {
        title = "새 메모"
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCancelButton))
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(didTapSaveButton))
        
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = saveButton
    }
    
    private func setConstraints() {
        let topInset:CGFloat = topbarHeight
        let bottomInset:CGFloat = 10
        let sideInset:CGFloat = 10
        let padding:CGFloat = 12
        
        
        titleTextField.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(sideInset)
            $0.top.equalToSuperview().inset(topInset)
            $0.height.equalToSuperview().multipliedBy(0.05)
        }
        
        memoTextView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(sideInset)
            $0.top.equalTo(titleTextField.snp.bottom).offset(padding)
            $0.height.equalToSuperview().multipliedBy(0.45)
        }
        
        addImageViewContainer.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(sideInset)
            $0.top.equalTo(memoTextView.snp.bottom).offset(padding)
            $0.bottom.equalToSuperview().offset(-bottomInset)
        }
    }
    
    private func createDismissKeyboardTapGesture() {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        view.addGestureRecognizer(tap)
    }
    
    func saveMemo() {
        guard let title = titleTextField.text else {
            presentAlertOnMainThread(title: "제목이 없습니다.", message: "제목을 입력하세요")
            return
        }
        guard let memo = memoTextView.text,
              memo.count > 0 else{
            presentAlertOnMainThread(title: "메모가 없습니다.", message: "메모를 입력하세요")
            return
        }
        let coreDataObjectArray = addedImages.coreDataRepresentation()
        
        DataManager.shared.addNewMemo(title: title, memo: memo, images: coreDataObjectArray)
        
        NotificationCenter.default.post(name:CreateNewMemoViewController.newMemoCreated, object: nil)
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapCancelButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapSaveButton() {
        saveMemo()
    }
    
    func add(childVC: UIViewController, to containerView: UIView) {
        addChild(childVC)
        containerView.addSubview(childVC.view)
        childVC.view.frame = containerView.bounds
        childVC.didMove(toParent: self)
    }
    
}
extension CreateNewMemoViewController {
    static let newMemoCreated = Notification.Name(rawValue: "newMemoCreated")
}

extension CreateNewMemoViewController: UITextFieldDelegate {
    
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            guard let text = textField.text, let range = Range(range, in: text) else {return true}
            let replacedText = text.replacingCharacters(in: range, with: string)
            
            guard replacedText.count <= 20 else { return false }
            
            return true
        }
        
}

extension CreateNewMemoViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = ""
            textView.textColor = .black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholderTextForTextView
            textView.textColor = .lightGray
        }
    }
}
