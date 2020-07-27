//
//  NotiLabel.swift
//  iOSMemoAppLinePlus
//
//  Created by SEONGJUN on 2020/02/16.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import UIKit

class NotiLabel: TitleLabel {
    override var intrinsicContentSize: CGSize {
        get {
            let originalIntrinsicContentSize = super.intrinsicContentSize
            let height = originalIntrinsicContentSize.height + 10
            layer.cornerRadius = height / 2
            layer.masksToBounds = true
            return CGSize(width: originalIntrinsicContentSize.width + 20, height: height)
        }
    }
}
//
//class CustomLabel: UILabel {
//    override var intrinsicContentSize: CGSize {
//        get {
//            let originalIntrinsicSize = super.intrinsicContentSize
//            let height = originalIntrinsicSize.height + 20
//            let width = originalIntrinsicSize.width + 20
//            layer.cornerRadius = height / 2
//            layer.masksToBounds = true
//            return CGSize(width: width, height: height)
//        }
//    }
//}
