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
    f.dateFormat = "yy-MM-dd HH:mm"
    f.locale = Locale(identifier: "Ko_kr")
    return f
}()

enum PlaceHolderImages {
    static let addedImage = UIImage(named: "photo")
    static let noImage = UIImage(named: "noimage")
    static let loading = UIImage(named: "loading")
}

enum MyColors {
    static let KeyColor = UIColor(red: 0/255, green: 186/255, blue: 0/255, alpha: 1)
    static let titleAndContents = UIColor(red: 255/255, green: 252/255, blue: 201/255, alpha: 1)
    static let brown = UIColor(red: 108/255, green: 71/255, blue: 57/255, alpha: 1)
    static let barColor = UIColor(red: 224/255, green: 217/255, blue: 209/255, alpha: 1)
    static let content = UIColor(red: 241/255, green: 236/255, blue: 230/255, alpha: 1)
}

enum EmptyStateViewImageName {
    static let list = "list"
    static let noPicture = "picture"
    static let offerImage = "offerPhoto"
}

enum VeryBottomViewTypeOfEmptyStateView {
    case memoList
    case detail
    case createNew
}

enum MyImageTypes {
    case image(UIImage)
    case urlString(String)
}


enum MainThumnailImageType : Int {
    case imageType = 0
    case urlType = 1
}

enum ScreenSize {
    static let width        = UIScreen.main.bounds.size.width
    static let height       = UIScreen.main.bounds.size.height
    static let maxLength    = max(ScreenSize.width, ScreenSize.height)
    static let minLength    = min(ScreenSize.width, ScreenSize.height)
}


enum DeviceTypes {
    static let idiom                    = UIDevice.current.userInterfaceIdiom
    static let nativeScale              = UIScreen.main.nativeScale
    static let scale                    = UIScreen.main.scale

    static let isiPhoneSE               = idiom == .phone && ScreenSize.maxLength == 568.0
    static let isiPhone8Standard        = idiom == .phone && ScreenSize.maxLength == 667.0 && nativeScale == scale
    static let isiPhone8Zoomed          = idiom == .phone && ScreenSize.maxLength == 667.0 && nativeScale > scale
    static let isiPhone8PlusStandard    = idiom == .phone && ScreenSize.maxLength == 736.0
    static let isiPhone8PlusZoomed      = idiom == .phone && ScreenSize.maxLength == 736.0 && nativeScale < scale
    static let isiPhoneX                = idiom == .phone && ScreenSize.maxLength == 812.0
    static let isiPhoneXsMaxAndXr       = idiom == .phone && ScreenSize.maxLength == 896.0
    static let isiPad                   = idiom == .pad && ScreenSize.maxLength >= 1024.0

    static func isiPhoneXAspectRatio() -> Bool {
        return isiPhoneX || isiPhoneXsMaxAndXr
    }
}
