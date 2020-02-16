//
//  MemoDetailViewController.swift
//  iOSMemoAppLinePlus
//
//  Created by SEONGJUN on 2020/02/13.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import UIKit

class MemoDetailViewController: CreateNewMemoViewController {

    var memo: Memo!
    var indexPath: IndexPath!
    var isFilteredBefore = false
    let collectionForEdit = ImageCollectionVCInCreateVC()
    var isContinuousEdit = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let collectionForDisplay = ImageCollectionVCInDetailVC()
        collectionForDisplay.memo = self.memo
        add(childVC: collectionForDisplay, to: addImageViewContainer)
        
        addImageViewContainer.backgroundColor = .white
        configure()
        setupNavigationBar()
        setTextEditingDisabled()
    }
    
    override func setupNavigationBar() {
        let backButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapBackButton))
        let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(didTapEditButton(_:)))
        navigationItem.leftBarButtonItem = backButton
        navigationItem.rightBarButtonItem = editButton
    }
    
    private func configure() {
        titleTextField.text = self.memo.title
        memoTextView.text = self.memo.content
    }
    
    func setTextEditingDisabled() {
        titleTextField.isUserInteractionEnabled = false
        memoTextView.isEditable = false
    }
    
    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func didTapEditButton(_ sender: UIBarButtonItem) {
        print("edit")
        if sender.title == "Edit" {
            titleTextField.isUserInteractionEnabled = true
            memoTextView.isEditable = true
            titleTextField.becomeFirstResponder()
            sender.title = "Save"
            switchingImageAddingViewEditMode()
            
        } else {
            titleTextField.isUserInteractionEnabled = false
            memoTextView.isEditable = false
            sender.title = "Edit"
            saveEditedMemo()
            switchingImageAddingViewDisplayMode()
        }
        
    }
    
    func switchingImageAddingViewEditMode() {
        if !isContinuousEdit {
            addImageViewContainer.subviews.first?.removeFromSuperview()
            addImageViewContainer.subviews[addImageViewContainer.subviews.endIndex - 1].removeFromSuperview()
        }
        isContinuousEdit = true
        addImageViewContainer.backgroundColor = .white
        
        collectionForEdit.imagesToAdd = memo.images?.imageArray()
        DispatchQueue.main.async {
            self.add(childVC: self.collectionForEdit, to: self.addImageViewContainer)
        }
    }
    
    func switchingImageAddingViewDisplayMode() {
        addImageViewContainer.subviews.first?.removeFromSuperview()
        let collectionForDisplay = ImageCollectionVCInDetailVC()
        collectionForDisplay.memo = DataManager.shared.memoList.first
        DispatchQueue.main.async {
            self.add(childVC: collectionForDisplay, to: self.addImageViewContainer)
        }
    }
    
    func saveEditedMemo() {
        guard let title = titleTextField.text else {
            presentAlertOnMainThread(title: "제목이 없습니다.", message: "제목을 입력하세요")
            return
        }
        guard let memo = memoTextView.text,
              memo.count > 0 else{
            presentAlertOnMainThread(title: "메모가 없습니다.", message: "메모를 입력하세요")
            return
        }
        
        if let imageForCoreData = collectionForEdit.imagesToAdd?.coreDataRepresentation() {
            if isFilteredBefore {
                let memoDate = DataManager.shared.filteredMemoList[indexPath.row].createdDate
                if let index = DataManager.shared.memoList.firstIndex(where: {$0.createdDate == memoDate}){
                    DataManager.shared.editMemo(index: index, title: title, memo: memo, images: imageForCoreData)
                    DataManager.shared.fetchMemo()
                }
            } else {
                DataManager.shared.editMemo(index: indexPath.row, title: title, memo: memo, images: imageForCoreData)
                DataManager.shared.fetchMemo()
            }
        } else {
            if isFilteredBefore {
                let memoDate = DataManager.shared.filteredMemoList[indexPath.row].createdDate
                if let index = DataManager.shared.memoList.firstIndex(where: {$0.createdDate == memoDate}){
                    DataManager.shared.editMemo(index: index, title: title, memo: memo, images: nil)
                    DataManager.shared.fetchMemo()
                }
            } else {
                DataManager.shared.editMemo(index: indexPath.row, title: title, memo: memo, images: nil)
                DataManager.shared.fetchMemo()
            }
        }
        
        
    }
    
    
    
    
    override func configureMemoTextView() {
        memoTextView.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        memoTextView.textColor = .black
    }
    
    deinit {
        print("DetailVC Deinit")
    }
    

}
