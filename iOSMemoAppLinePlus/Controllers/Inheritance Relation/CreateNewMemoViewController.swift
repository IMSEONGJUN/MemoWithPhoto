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
    var isMemoEditing = true
    
    let noticeLabel = TitleLabel(textAlignment: .left, fontSize: 15)
    
    var addedImages = [MyImageTypes]()
    
    var addImageViewContainer = UIView()
    let imageCollectionVC = ImageCollectionForCreateAndEdit()
    
    
    // MARK:  - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupNavigationBar()
        setConstraints()
        addChildViewController()
        createDismissKeyboardTapGesture()
    }
    
    func addChildViewController() {
        checkSelfHaveChildrenVC(on: self)
        imageCollectionVC.delegate = self
        add(childVC: imageCollectionVC, to: addImageViewContainer)
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        [titleTextField, memoTextView, noticeLabel, addImageViewContainer].forEach({view.addSubview($0)})
        configureTitleTextField()
        configureMemoTextView()
        configureNoticeLabel()
    }
    
    func setupNavigationBar() {
        title = "새 메모"
        let cancelButton = UIBarButtonItem(title: ButtonsNameOnNavigationBar.cancel, style: .plain, target: self, action: #selector(didTapCancelButton))
        let saveButton = UIBarButtonItem(title: ButtonsNameOnNavigationBar.save, style: .plain, target: self, action: #selector(didTapSaveButton))
        
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = saveButton
    }
    
    private func configureTitleTextField() {
        let titleTextFieldPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 6, height: titleTextField.frame.height))
        titleTextField.leftView = titleTextFieldPaddingView
        titleTextField.backgroundColor = MyColors.content
        titleTextField.leftViewMode = .always
        titleTextField.autocorrectionType = .no
        titleTextField.keyboardType = .default
        titleTextField.placeholder = "제목"
        titleTextField.layer.cornerRadius = 5
        titleTextField.clipsToBounds = true
        titleTextField.delegate = self
    }
    
    func configureMemoTextView() {
        memoTextView.backgroundColor = MyColors.content
        memoTextView.text = self.placeholderTextForTextView
        memoTextView.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        memoTextView.textColor = .lightGray
        memoTextView.layer.cornerRadius = 5
        memoTextView.clipsToBounds = true
        memoTextView.autocorrectionType = .no
        memoTextView.delegate = self
    }
    
    func configureNoticeLabel() {
        noticeLabel.text = " 사진을 꾹 누르면 이동이 가능합니다."
        noticeLabel.alpha = 0
    }
    
    private func setConstraints() {
        let topInset:CGFloat = topbarHeight + 10
        let bottomInset:CGFloat = 10
        let sideInset:CGFloat = 10
        let titleAndMemoPadding:CGFloat = 12
        let memoAndImagePadding:CGFloat = 50
        
        
        titleTextField.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(sideInset)
            $0.top.equalToSuperview().inset(topInset)
            $0.height.equalToSuperview().multipliedBy(0.05)
        }
        
        memoTextView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(sideInset)
            $0.top.equalTo(titleTextField.snp.bottom).offset(titleAndMemoPadding)
            $0.height.equalToSuperview().multipliedBy(0.35)
        }
        
        addImageViewContainer.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(sideInset)
            $0.top.equalTo(memoTextView.snp.bottom).offset(memoAndImagePadding)
            $0.bottom.equalToSuperview().offset(-bottomInset)
        }
        
        noticeLabel.snp.makeConstraints {
            $0.top.leading.equalTo(addImageViewContainer)
        }
        
    }
    
    private func createDismissKeyboardTapGesture() {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        view.addGestureRecognizer(tap)
    }
    
    deinit{
        print("CreateNewMemoVC Deinit")
    }
    
    
    // MARK: - Action
    
    func saveMemo() {
        guard let title = titleTextField.text, title.count > 0 else {
            presentAlertOnMainThread(title: "제목이 없습니다.", message: "제목을 입력하세요")
            titleTextField.becomeFirstResponder()
            return
        }
        guard let memo = memoTextView.text,
              memo.count > 0, memo != placeholderTextForTextView else{
            presentAlertOnMainThread(title: "메모가 없습니다.", message: "메모를 입력하세요")
            memoTextView.becomeFirstResponder()
            return
        }
        if addedImages.isEmpty {
            DataManager.shared.addNewMemo(title: title, memo: memo, images: nil)
        } else {
            guard let coreDataObjectArray = addedImages.convertToCoreDataRepresentation() else {return}
            DataManager.shared.addNewMemo(title: title, memo: memo, images: coreDataObjectArray)
        }
        
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

extension CreateNewMemoViewController: ImageCollectionForCreateAndEditDelegate {
    func collectionViewHaveImageMoreThanOne(isHave: Bool) {
        DispatchQueue.main.async {
            if isHave {
                UIView.animate(withDuration: 0.5) {
                    self.noticeLabel.transform = CGAffineTransform(translationX: 0, y: -self.noticeLabel.frame.size.height)
                    self.noticeLabel.alpha = 1.0
                }
            } else {
                UIView.animate(withDuration: 0.5) {
                    self.noticeLabel.transform = .identity
                    self.noticeLabel.alpha = 0.0
                }
            }
        }
    }
    
    
    
    
}
