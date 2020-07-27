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

enum ImageLoadError: String, Error {
    case invalidUrl = "잘못된 URL입니다. 다시 입력해주세요."
    case invalidResponse = "서버로부터의 응답이 잘못되었습니다. 다시 시도해주세요."
    case unableToComplete = "이미지를 불러올 수 없습니다. 인터넷 연결상태를 체크해주세요."
    case invaildData = "해당 URL의 이미지가 없습니다. 다시 시도해주세요."
}

enum PlaceHolderImages {
    static let defaultWhenNoImage = UIImage(named: "noImage")
    static let imageLoadFail = UIImage(named: "noimage")
    static let loading = UIImage(named: "loading")
    static let removeImage = UIImage(named: "remove")
    static let next = UIImage(named: "goNext")
}

enum MyColors {
    static let KeyColor = UIColor(red: 0/255, green: 186/255, blue: 0/255, alpha: 1)
    static let brown = UIColor(red: 108/255, green: 71/255, blue: 57/255, alpha: 1)
    static let barColor = UIColor(red: 224/255, green: 217/255, blue: 209/255, alpha: 1)
    static let content = UIColor(red: 241/255, green: 236/255, blue: 230/255, alpha: 1)
    static let title = UIColor(red: 105/255, green: 79/255, blue: 66/255, alpha: 1)
    static let body = UIColor(red: 151/255, green: 134/255, blue: 125/255, alpha: 1)
}

enum MyImageTypes {
    case image(UIImage)
    case urlString(String)
}

enum Titles {
    static let select = "선택"
    static let info = "알림"
    static let error = "에러"
    static let title = "제목"
    static let imageDetail = "이미지 상세보기"
}

enum ButtonNames {
    static let save = "저장"
    static let cancel = "취소"
    static let edit = "수정"
    static let remove = "삭제"
    static let back = "나가기"
    static let confirm = "확인"
    static let newMemo = "새 메모"
    static let yes = "예"
    static let no = "아니오"
    static let addImage = "이미지 추가"
    static let takePicture = "사진 찍기"
    static let fromAlbum = "앨범에서 선택"
    static let fromUrl = "URL로 가져오기"
    static let search = "검색"
    static let loadPicture = "사진 불러오기"
    static let deletePicture = "사진 지우기"
    static let usePicture = "사진 사용하기"
    static let urlInput = "URL 입력"
}

enum TextMessages {
    static let attachPicture = "사진을 등록하실 수 있습니다."
    static let noImages = "등록된 이미지가 없습니다."
    static let noMemos = "메모가 없습니다.\n 새 메모를 만들어보세요!"
    static let inputUrl = "URL을 입력하세요"
    static let inputMemoDetail = "메모 내용을 입력하세요."
    static let failedToLoad = "이미지를 불러오지 못했습니다. \n 다시 시도해주세요."
    static let dragSupport = "사진을 꾹 누르면 이동이 가능합니다."
    static let noTitle = "제목이 없습니다."
    static let enterTitle = "제목을 입력하세요."
    static let noMemoDetail = "메모가 없습니다."
    static let enterMemoDetail = "메모를 입력하세요."
    static let confirmDeleteMemo = "메모를 삭제하시겠습니까?"
}

enum EmptyStateViewImageName {
    static let list = "list"
    static let noPicture = "noPicture"
    static let offerImage = "offerPhoto"
}

enum VeryBottomViewTypeOfEmptyStateView {
    case memoList
    case detail
    case createNew
}


// Use when want to make difference for each Device
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
