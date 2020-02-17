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
//    var isContinuousEdit = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addImageViewContainer.backgroundColor = .white
        configure()
//        setupNavigationBar()
        setTextEditingDisabled()
    }
    
    override func addChildViewController() {
        let collectionForDisplay = ImageCollectionVCInDetailVC()
//        collectionForDisplay.memo = self.memo
        add(childVC: collectionForDisplay, to: addImageViewContainer)
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
            
        } else if sender.title == "Save" {
            let success = saveEditedMemo()
            guard success else {return}
            titleTextField.isUserInteractionEnabled = false
            memoTextView.isEditable = false
            sender.title = "Edit"
            switchingImageAddingViewDisplayMode()
        }
        
    }
    
    func switchingImageAddingViewEditMode() {
        if self.children.count > 0{
            self.children.forEach({ $0.willMove(toParent: nil); $0.view.removeFromSuperview(); $0.removeFromParent() })
        }
        collectionForEdit.imagesToAdd = memo.images?.imageArray()
        DispatchQueue.main.async {
            self.add(childVC: self.collectionForEdit, to: self.addImageViewContainer)
        }
    }
    
    func switchingImageAddingViewDisplayMode() {
        let collectionForDisplay = ImageCollectionVCInDetailVC()
        collectionForDisplay.memo = DataManager.shared.memoList.first

        if self.children.count > 0{
            self.children.forEach({ $0.willMove(toParent: nil); $0.view.removeFromSuperview(); $0.removeFromParent() })
        }
        DispatchQueue.main.async {
            self.add(childVC: collectionForDisplay, to: self.addImageViewContainer)
            if self.memo.images?.imageArray() == nil{
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
              memo.count > 0 else{
            presentAlertOnMainThread(title: "메모가 없습니다.", message: "메모를 입력하세요")
            return false
        }
        
        if let imageForCoreData = collectionForEdit.imagesToAdd?.coreDataRepresentation() {
            if isFilteredBefore {
                let memoDateInfilteredList = DataManager.shared.filteredMemoList[indexPath.row].createdDate
                if let index = DataManager.shared.memoList.firstIndex(where: {$0.createdDate == memoDateInfilteredList}){
                    DataManager.shared.editMemo(index: index, title: title, memo: memo, images: imageForCoreData)
//                    DataManager.shared.fetchMemo()
                    self.memo = DataManager.shared.memoList.first
                }
            } else {
                DataManager.shared.editMemo(index: indexPath.row, title: title, memo: memo, images: imageForCoreData)
//                DataManager.shared.fetchMemo()
                self.memo = DataManager.shared.memoList.first
            }
        } else {
            if isFilteredBefore {
                let memoDate = DataManager.shared.filteredMemoList[indexPath.row].createdDate
                if let index = DataManager.shared.memoList.firstIndex(where: {$0.createdDate == memoDate}){
                    DataManager.shared.editMemo(index: index, title: title, memo: memo, images: nil)
//                    DataManager.shared.fetchMemo()
                    self.memo = DataManager.shared.memoList.first
                }
            } else {
                DataManager.shared.editMemo(index: indexPath.row, title: title, memo: memo, images: nil)
//                DataManager.shared.fetchMemo()
                self.memo = DataManager.shared.memoList.first
            }
        }
        return true
        
    }
    
    
    
    
    override func configureMemoTextView() {
        memoTextView.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        memoTextView.textColor = .black
    }
    
    deinit {
        print("DetailVC Deinit")
    }
    

}
