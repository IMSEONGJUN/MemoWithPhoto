//
//  MemoDetailViewController.swift
//  iOSMemoAppLinePlus
//
//  Created by SEONGJUN on 2020/02/13.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import UIKit

protocol MemoDetailViewControllerDelegate: class {
    func removeTableViewRow(indexPath: IndexPath, isSearching: Bool)
}


class MemoDetailViewController: CreateNewMemoViewController {
    
    // MARK: Properties
    var memo: Memo!
    var indexPath: IndexPath!
    var isFilteredBefore = false
    var collectionForEdit: ImageCollectionForCreateAndEdit?
    
    weak var delegate: MemoDetailViewControllerDelegate?
    
    var backOrCancelButton = UIBarButtonItem()
    var editOrSaveButton = UIBarButtonItem()
    
    
    // MARK: LifeCycle
    override init() {
        super.init()
        print("init MemoDetailViewController")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addImageViewContainer.backgroundColor = .white
        configure()
        setTextEditingDisabled()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        backOrCancelButton.title = ButtonNames.back // 버그 발견하여 line.40 코드 지워서 해결
    }
    
    deinit {
        print("DetailVC Deinit")
    }
    
    
    // MARK: - Setup
    
    override func addChildViewController() {
        addChildToSelf()
    }
    
    func addChildToSelf() {
        checkSelfHaveChildrenVC(on: self)
        let collectionForDetail = ImageCollectionForDetail()
        add(childVC: collectionForDetail, to: addImageViewContainer)
    }
    
    
    // MARK: - Overridden Setup Method
    
    override func setupNavigationBar() {
        print("detailVC setNavi")
        backOrCancelButton = UIBarButtonItem(title: ButtonNames.back,
                                             style: .plain,
                                             target: self,
                                             action: #selector(didTapBackOrCancelButton(_:)))
        editOrSaveButton = UIBarButtonItem(title: ButtonNames.edit,
                                           style: .plain,
                                           target: self,
                                           action: #selector(didTapEditOrSaveButton(_:)))
        let removeButton = UIBarButtonItem(title: ButtonNames.remove,
                                           style: .plain,
                                           target: self,
                                           action: #selector(didTapRemoveButton))
        
        navigationItem.leftBarButtonItem = backOrCancelButton
        navigationItem.rightBarButtonItems = [editOrSaveButton, removeButton]
    }
    
    override func configureMemoTextView() {
        print("detailVC configureTextView")
        memoTextView.backgroundColor = MyColors.content
        memoTextView.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        memoTextView.textColor = .black
        memoTextView.layer.cornerRadius = 5
        memoTextView.clipsToBounds = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapTextViewToEdit))
        memoTextView.addGestureRecognizer(tapGesture)
    }
    
    
    // MARK: - Setup
    
    private func configure() {
        print("detailVC configure")
        titleTextField.text = self.memo.title
        memoTextView.text = self.memo.content
    }
    
    func setTextEditingDisabled() {
        titleTextField.isUserInteractionEnabled = false
        memoTextView.isEditable = false
    }
    
    
    // MARK: - Action Handle
    
    @objc private func didTapTextViewToEdit() {
        titleTextField.isUserInteractionEnabled = true
        memoTextView.isEditable = true
        memoTextView.becomeFirstResponder()
        editOrSaveButton.title = ButtonNames.save
        backOrCancelButton.title = ButtonNames.cancel
        switchingImageAddingViewEditMode()
    }
    
    @objc private func didTapBackOrCancelButton(_ sender: UIBarButtonItem) {
        switch sender.title {
        case ButtonNames.back:
            navigationController?.popViewController(animated: true)
        case ButtonNames.cancel:
            configure()
            setTextEditingDisabled()
            addChildToSelf()

            self.editOrSaveButton.title = ButtonNames.edit
            self.backOrCancelButton.title = ButtonNames.back
            UIView.animate(withDuration: 0.5) {
                self.noticeLabel.transform = .identity
                self.noticeLabel.alpha = 0.0
            }
        default:
            break
        }
        
    }
    
    @objc private func didTapRemoveButton() {
        confirmDeleteMemo(title: Titles.info,
                          message: TextMessages.confirmDeleteMemo,
                          handler: {
                              DataManager.shared.removeMemo(indexPath: self.indexPath,
                                                            isInFilteredMemoList: self.isFilteredBefore)
                              self.delegate?.removeTableViewRow(indexPath: self.indexPath,
                                                                isSearching: false)
                              self.navigationController?.popViewController(animated: true)
                          })
    }
    
    @objc private func didTapEditOrSaveButton(_ sender: UIBarButtonItem) {
        if sender.title == ButtonNames.edit {
            titleTextField.isUserInteractionEnabled = true
            memoTextView.isEditable = true
            titleTextField.becomeFirstResponder()
            sender.title = ButtonNames.save
            backOrCancelButton.title = ButtonNames.cancel
            switchingImageAddingViewEditMode()
            
        } else if sender.title == ButtonNames.save {
            let success = saveEditedMemo()
            guard success else { return }
            setTextEditingDisabled()
            sender.title = ButtonNames.edit
            backOrCancelButton.title = ButtonNames.back
            switchingImageAddingViewDisplayMode()
            UIView.animate(withDuration: 0.5) {
                self.noticeLabel.transform = .identity
                self.noticeLabel.alpha = 0.0
            }
        }
    }
    
    func switchingImageAddingViewEditMode() {
        checkSelfHaveChildrenVC(on: self)
        collectionForEdit = ImageCollectionForCreateAndEdit()
        collectionForEdit?.delegate = self
        collectionForEdit?.imagesToAdd = memo.images?.convertToMyImageTypeArray()
        self.add(childVC: self.collectionForEdit!, to: self.addImageViewContainer)
    }
    
    func switchingImageAddingViewDisplayMode() {
        let collectionForDisplay = ImageCollectionForDetail()
        collectionForDisplay.memo = DataManager.shared.memoList.first // self.memo로 수정하는 것이 좋겠음. 수정 메모를 저장에 성공하면
                                                                      // DataManager.shared.memoList.first 값을 self.memo로 가져온다
        checkSelfHaveChildrenVC(on: self)
        self.add(childVC: collectionForDisplay, to: self.addImageViewContainer)
        if self.memo.images?.convertToMyImageTypeArray() == nil{
            collectionForDisplay.showEmptyStateViewOnDetailVC()
        }
    }
    
    func saveEditedMemo() -> Bool {
        guard let title = titleTextField.text, title.count > 0 else {
            presentAlertOnMainThread(title: TextMessages.noTitle, message: TextMessages.enterTitle)
            titleTextField.becomeFirstResponder()
            return false
        }
        guard let memo = memoTextView.text, memo.count > 0, memo != placeholderTextForTextView else {
            presentAlertOnMainThread(title: TextMessages.noMemoDetail, message: TextMessages.enterMemoDetail)
            return false
        }
        
        let imageForCoreData = collectionForEdit?.imagesToAdd?.convertToDataType()
        if isFilteredBefore {
            let memoDateInfilteredList = DataManager.shared.filteredMemoList[indexPath.row].createdDate
            if let index = DataManager.shared.memoList.firstIndex(where: {$0.createdDate == memoDateInfilteredList}) {
                DataManager.shared.editMemo(index: index, title: title, memo: memo, images: imageForCoreData)
            }
        } else {
            DataManager.shared.editMemo(index: indexPath.row, title: title, memo: memo, images: imageForCoreData)
        }
        
        indexPath.row = 0
        self.memo = DataManager.shared.memoList.first
        return true
        
    }
    
    func confirmDeleteMemo(title: String, message: String, handler:(() -> ())?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: ButtonNames.yes, style: .default) { (_) in
            handler?()
        }
        let no = UIAlertAction(title: ButtonNames.no, style: .cancel)
        alert.addAction(ok)
        alert.addAction(no)
        present(alert, animated: true)
    }
    
    
    // MARK: - Overridden ImageCollectionForCreateAndEditDelegate Method
    
    override func collectionViewHasImageMoreThanOne(hasImage: Bool) {
        super.collectionViewHasImageMoreThanOne(hasImage: hasImage)
//        if hasImage {
//            UIView.animate(withDuration: 0.5) {
//                self.noticeLabel.transform = CGAffineTransform(translationX: 0,
//                                                               y: -self.noticeLabel.frame.size.height)
//                self.noticeLabel.alpha = 1.0
//            }
//        } else {
//            UIView.animate(withDuration: 0.5) {
//                self.noticeLabel.transform = .identity
//                self.noticeLabel.alpha = 0.0
//            }
//        }
    }
    
}
