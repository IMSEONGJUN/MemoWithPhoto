//
//  UIViewController+Ext.swift
//  iOSMemoAppLinePlus
//
//  Created by SEONGJUN on 2020/02/15.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import UIKit

fileprivate var containerView: UIView!

extension UIViewController {
    
    var topbarHeight: CGFloat {
       return UIApplication.shared.statusBarFrame.size.height +
                (self.navigationController?.navigationBar.frame.height ?? 0.0)
    }
    
    func presentAlertOnMainThread(title: String, message: String, buttonTitle: String = ButtonNames.confirm) {
        DispatchQueue.main.async {
            let alertVC = AlertViewController(title: title, message: message, buttonTitle: buttonTitle)
            alertVC.modalPresentationStyle = .overFullScreen
            alertVC.modalTransitionStyle = .crossDissolve
            self.present(alertVC, animated: true)
        }
    }
    
    func showEmptyStateView(with message: String, in view: UIView, imageName: String,
                            superViewType: VeryBottomViewTypeOfEmptyStateView) {
        let emptyStateView = EmptyStateView(message: message, imageName: imageName)
        if imageName == EmptyStateViewImageName.offerImage || imageName == EmptyStateViewImageName.noPicture {
            emptyStateView.isOnTheCreateNewOrDetailVC = true
            if superViewType == .detail {
                emptyStateView.createNewButton.isHidden = true
            }
        }

        addChild(emptyStateView)
        view.addSubview(emptyStateView.view)
        emptyStateView.view.frame = view.bounds
        emptyStateView.didMove(toParent: self)
    }
    
    func checkSelfHaveChildrenVC(on selfView: UIViewController ) {
        if selfView.children.count > 0 {
            selfView.children.forEach({
                $0.willMove(toParent: nil)
                $0.view.removeFromSuperview()
                $0.removeFromParent()
            })
        }
    }
    
    func showLoadingView() {
        containerView = UIView(frame: view.bounds)
        view.addSubview(containerView)
        containerView.backgroundColor = .white
        containerView.alpha = 0
        
        UIView.animate(withDuration: 0.25) { containerView.alpha = 0.5 }
        
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.color = .green
        containerView.addSubview(activityIndicator)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -70),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        activityIndicator.startAnimating()
    }
    
    func dismissLoadingView() {
        DispatchQueue.main.async {
            containerView.removeFromSuperview()
            containerView = nil
        }
    }
}

