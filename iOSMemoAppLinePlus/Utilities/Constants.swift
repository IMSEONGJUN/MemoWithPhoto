//
//  Constants.swift
//  iOSMemoAppLinePlus
//
//  Created by SEONGJUN on 2020/02/13.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import UIKit

let formatter: DateFormatter = {
   let f = DateFormatter()
    f.dateStyle = .long
    f.timeStyle = .short
    f.locale = Locale(identifier: "Ko_kr")
    return f
}()

enum PlaceHolderImages {
    static let addedImage = UIImage(named: "photo")
}

enum MyColors {
    static let KeyColor = UIColor(red: 0/255, green: 186/255, blue: 0/255, alpha: 1)
}

enum EmptyStateViewImageName {
    static let list = "list"
    static let picture = "picture"
}

enum VeryBottomViewTypeOfEmptyStateView {
    case memoList
    case detail
    case createNew
}
