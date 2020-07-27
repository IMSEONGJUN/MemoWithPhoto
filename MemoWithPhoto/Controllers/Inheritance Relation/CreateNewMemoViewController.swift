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
       
    // MARK: Properties
    var titleTextField = UITextField()
    var memoTextView = UITextView()
    let placeholderTextForTextView = TextMessages.inputMemoDetail
    var isMemoEditing = true // 불필요한 코드
    let noticeLabel = TitleLabel(textAlignment: .left, fontSize: 15)
    var addedImages = [MyImageTypes]()
    var addImageViewContainer = UIView()
    let imageCollectionVC = ImageCollectionForCreateAndEdit()
    
    
    // MARK: LifeCycle
    init() {
        super.init(nibName: nil, bundle: nil)
        print("init CreateNewMemoViewController")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupNavigationBar()
        setConstraints()
        addChildViewController()
        createDismissKeyboardTapGesture()
    }
    
    deinit {
        print("CreateNewMemoVC Deinit")
    }
    
    
    // MARK: - Setup
    
    func addChildViewController() {
        checkSelfHaveChildrenVC(on: self)
        imageCollectionVC.delegate = self
        add(childVC: imageCollectionVC, to: addImageViewContainer)
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        [titleTextField, memoTextView, noticeLabel, addImageViewContainer].forEach({ view.addSubview($0) })
        configureTitleTextField()
        configureMemoTextView()
        configureNoticeLabel()
    }
    
    func setupNavigationBar() {
        print("CreateVC setNavi")
        title = ButtonNames.newMemo
        navigationController?.navigationBar.barTintColor = MyColors.barColor
        let cancelButton = UIBarButtonItem(title: ButtonNames.cancel,
                                           style: .plain,
                                           target: self,
                                           action: #selector(didTapCancelButton))
        let saveButton = UIBarButtonItem(title: ButtonNames.save,
                                         style: .plain,
                                         target: self,
                                         action: #selector(didTapSaveButton))
        
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = saveButton
    }
    
    private func configureTitleTextField() {
        let titleTextFieldPaddingView = UIView(frame: CGRect(x: 0,
                                                             y: 0,
                                                             width: 6,
                                                             height: titleTextField.frame.height))
        titleTextField.leftView = titleTextFieldPaddingView
        titleTextField.backgroundColor = MyColors.content
        titleTextField.leftViewMode = .always
        titleTextField.autocorrectionType = .no
        titleTextField.keyboardType = .default
        titleTextField.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        titleTextField.textColor = .black
        titleTextField.placeholder = Titles.title
        titleTextField.layer.cornerRadius = 5
        titleTextField.clipsToBounds = true
        titleTextField.delegate = self
    }
    
    func configureMemoTextView() {
        print("CreateVC configureTextView")
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
        noticeLabel.text = TextMessages.dragSupport
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
    
   
    
    // MARK: - Action Handle
    
    func saveMemo() {
        guard let title = titleTextField.text, title.count > 0 else {
            presentAlertOnMainThread(title: TextMessages.noTitle, message: TextMessages.enterTitle)
            titleTextField.becomeFirstResponder()
            return
        }
        guard let memo = memoTextView.text,
              memo.count > 0, memo != placeholderTextForTextView else{
                presentAlertOnMainThread(title: TextMessages.noMemoDetail, message: TextMessages.enterMemoDetail)
            memoTextView.becomeFirstResponder()
            return
        }
        if addedImages.isEmpty {
            DataManager.shared.addNewMemo(title: title, memo: memo, images: nil)
        } else {
            guard let coreDataObjectArray = addedImages.convertToDataType() else { return }
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


    // MARK: - Notification Name
extension CreateNewMemoViewController {
    static let newMemoCreated = Notification.Name(rawValue: "newMemoCreated")
}


    // MARK: - UITextFieldDelegate

extension CreateNewMemoViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text, let range = Range(range, in: text) else { return true }
        
        let replacedText = text.replacingCharacters(in: range, with: string)
        guard replacedText.count <= 20 else { return false }
        return true
    }
}


    // MARK: - UITextViewDelegate

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


    // MARK: - ImageCollectionForCreateAndEditDelegate

extension CreateNewMemoViewController: ImageCollectionForCreateAndEditDelegate {
    func collectionViewHasImageMoreThanOne(hasImage: Bool) {
        if hasImage {
            UIView.animate(withDuration: 0.5) {
                self.noticeLabel.transform = CGAffineTransform(translationX: 0,
                                                               y: -self.noticeLabel.frame.size.height)
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
