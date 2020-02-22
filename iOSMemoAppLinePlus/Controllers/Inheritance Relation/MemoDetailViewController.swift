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

    var memo: Memo!
    var indexPath: IndexPath!
    var isFilteredBefore = false
    let collectionForEdit = ImageCollectionForCreateAndEdit()
    
    weak var delegate: MemoDetailViewControllerDelegate?
    
    var backOrCancelButton = UIBarButtonItem()
    var editOrSaveButton = UIBarButtonItem()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addImageViewContainer.backgroundColor = .white
        configure()
        setTextEditingDisabled()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        backOrCancelButton.title = "나가기"
    }
    
    override func addChildViewController() {
        addChildToSelf()
    }
    
    func addChildToSelf() {
        checkSelfHaveChildrenVC(on: self)
        let collectionForDetail = ImageCollectionForDetail()
        add(childVC: collectionForDetail, to: addImageViewContainer)
    }
    
    override func setupNavigationBar() {
        backOrCancelButton = UIBarButtonItem(title: ButtonNames.back, style: .plain, target: self, action: #selector(didTapBackOrCancelButton(_:)))
        editOrSaveButton = UIBarButtonItem(title: ButtonNames.edit, style: .plain, target: self, action: #selector(didTapEditOrSaveButton(_:)))
        let removeButton = UIBarButtonItem(title: ButtonNames.remove, style: .plain, target: self, action: #selector(didTapRemoveButton))
        navigationItem.leftBarButtonItem = backOrCancelButton
        navigationItem.rightBarButtonItems = [editOrSaveButton, removeButton]
    }
    
    override func configureMemoTextView() {
        memoTextView.backgroundColor = MyColors.content
        memoTextView.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        memoTextView.textColor = .black
        memoTextView.layer.cornerRadius = 5
        memoTextView.clipsToBounds = true
    }
    
    private func configure() {
        titleTextField.text = self.memo.title
        memoTextView.text = self.memo.content
    }
    
    func setTextEditingDisabled() {
        titleTextField.isUserInteractionEnabled = false
        memoTextView.isEditable = false
    }
    
    @objc private func didTapBackOrCancelButton(_ sender: UIBarButtonItem) {
        switch sender.title {
        case ButtonNames.back:
             navigationController?.popViewController(animated: true)
        case ButtonNames.cancel:
            configure()
            setTextEditingDisabled()
            addChildToSelf()
            DispatchQueue.main.async {
                self.editOrSaveButton.title = ButtonNames.edit
                self.backOrCancelButton.title = ButtonNames.back
                UIView.animate(withDuration: 0.5) {
                    self.noticeLabel.transform = .identity
                    self.noticeLabel.alpha = 0.0
                }
            }
        default:
            break
        }
        
    }
    
    @objc private func didTapRemoveButton() {
        deleteOrNotAlert(title: "알림", message: "메모를 삭제하시겠습니까?")
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
            guard success else {return}
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
        collectionForEdit.delegate = self
        collectionForEdit.imagesToAdd = memo.images?.convertToMyImageTypeArray()
        self.add(childVC: self.collectionForEdit, to: self.addImageViewContainer)
    }
    
    func switchingImageAddingViewDisplayMode() {
        let collectionForDisplay = ImageCollectionForDetail()
        collectionForDisplay.memo = DataManager.shared.memoList.first

        checkSelfHaveChildrenVC(on: self)
        DispatchQueue.main.async {
            self.add(childVC: collectionForDisplay, to: self.addImageViewContainer)
            if self.memo.images?.convertToMyImageTypeArray() == nil{
                collectionForDisplay.showEmptyStateViewOnDetailVC()
            }
        }
    }
    
    func saveEditedMemo() -> Bool {
        guard let title = titleTextField.text, title.count > 0 else {
            presentAlertOnMainThread(title: "제목이 없습니다.", message: "제목을 입력하세요")
            titleTextField.becomeFirstResponder()
            return false
        }
        guard let memo = memoTextView.text,
              memo.count > 0, memo != placeholderTextForTextView else{
            presentAlertOnMainThread(title: "메모가 없습니다.", message: "메모를 입력하세요")
            return false
        }
        
        if let imageForCoreData = collectionForEdit.imagesToAdd?.convertToCoreDataRepresentation() {
            if isFilteredBefore {
                let memoDateInfilteredList = DataManager.shared.filteredMemoList[indexPath.row].createdDate
                if let index = DataManager.shared.memoList.firstIndex(where: {$0.createdDate == memoDateInfilteredList}){
                    DataManager.shared.editMemo(index: index, title: title, memo: memo, images: imageForCoreData)
                }
            } else {
                DataManager.shared.editMemo(index: indexPath.row, title: title, memo: memo, images: imageForCoreData)
            }
        } else {
            if isFilteredBefore {
                let memoDateInfilteredList = DataManager.shared.filteredMemoList[indexPath.row].createdDate
                if let index = DataManager.shared.memoList.firstIndex(where: {$0.createdDate == memoDateInfilteredList}){
                    DataManager.shared.editMemo(index: index, title: title, memo: memo, images: nil)
                }
            } else {
                DataManager.shared.editMemo(index: indexPath.row, title: title, memo: memo, images: nil)
                
            }
        }
        self.memo = DataManager.shared.memoList.first
        return true
        
    }
    
    func deleteOrNotAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "네", style: .default) { (_) in
            DataManager.shared.removeMemo(indexPath: self.indexPath, isInFilteredMemoList: self.isFilteredBefore)
            self.delegate?.removeTableViewRow(indexPath: self.indexPath, isSearching: false)
            self.navigationController?.popViewController(animated: true)
        }
        let no = UIAlertAction(title: "아니요", style: .cancel)
        alert.addAction(ok)
        alert.addAction(no)
        present(alert, animated: true)
    }
    
    deinit {
        print("DetailVC Deinit")
    }
    
    override func collectionViewHasImageMoreThanOne(hasImage: Bool) {
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
