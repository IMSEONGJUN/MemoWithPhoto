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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        add(childVC: ImageCollectionVCInDetailVC(), to: addImageViewContainer)
        configure()
        setTextEditingDisabled()
    }
    

    override func add(childVC: UIViewController, to containerView: UIView) {
        addChild(childVC)
        containerView.addSubview(childVC.view)
        childVC.view.frame = containerView.bounds
        childVC.didMove(toParent: self)
    }
    
    private func configure() {
        titleTextField.text = self.memo.title
        memoTextView.text = self.memo.content
    }
    
    func setTextEditingDisabled() {
        titleTextField.isUserInteractionEnabled = false
        memoTextView.isEditable = false
    }

}
