//
//  Array+Ext.swift
//  iOSMemoAppLinePlus
//
//  Created by SEONGJUN on 2020/02/14.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import UIKit


extension Array where Element == MyImageTypes { //
    
    // Convert [MyImageTypes] To Data? For Saving in CoreData
    func convertToDataType() -> Data? {
        let CDataArray = NSMutableArray() // NSArray는 수정이 불가하기 때문에 NSMutableArray 사용함

        for img in self {
            switch img {
            case .image(let val):
                guard let imageRepresentation = val.jpegData(compressionQuality: 0.5) else {
                    print("Unable to represent image as JPEG Data")
                    return nil
                }
                let nsdata : NSData = NSData(data: imageRepresentation)
                CDataArray.add(nsdata)
                //일반 Data 타입은 NSCoding 프로토콜을 따르지 않기 때문에 archive를 위해 NSCoding 프로토콜을 따르는 NSData타입으로 변환 후 사용. 그렇게 되면 NSMutableArray와 그안의 element인 NSData 모두 NSCoding 프로토콜을 따르는 클래스들이기 때문에 NSKeyedArchiver으로 한번에 압축된다.
            case .urlString(let val):
                let data = Data(val.utf8) //utf8은 유니코드를 위한 문자 인코딩 방식중 하나
                let nsdata : NSData = NSData(data: data)
                CDataArray.add(nsdata)
            }
        }
        return NSKeyedArchiver.archivedData(withRootObject: CDataArray) // 데이터 타입으로 변환하여 압축한다.
    } // NSKeyedArchiver.archivedData 를 사용하여 데이터 타입으로 압축하려면 NSCoding프로토콜을 준수하는 타입이어야 하는데 일반 Array로 하면 MyImageType에 프로토콜 채택 및 메소드 구현해줘야 하기 때문에 기본적으로 NSCoding을 준수하는 NSArray 혹은 NSMutableArray로 해준것. 그 중 수정가능한 NSMutableArray를 사용한 것.
}
//NSKeyedArchiver.archivedData(withRootObject: CDataArray) 이거 호출될 때  NSMutableArray 내부적으로 NSCoding의 메소드 중
//encode(with aCoder:) - encoding 이게 호출


//public protocol NSCoding {
//
//    func encode(with coder: NSCoder)
//
//    init?(coder: NSCoder) // NS_DESIGNATED_INITIALIZER
//}


extension Data {
    
    // Convert Data To [MyImageTypes]? For Displaying on Views
    func convertToMyImageTypeArray() -> [MyImageTypes]? {
        var myImageArray = [MyImageTypes]()
        
        if let mySavedData = NSKeyedUnarchiver.unarchiveObject(with: self) as? NSArray { // MyImageType 배열의 값이 수정되지 않도록 게런티하기 위해 NSArray 사용
            for data in mySavedData {
                if let image = UIImage(data: data as! Data) {
                    let type = MyImageTypes.image(image)
                    myImageArray.append(type)
                } else if let string = String(data: data as! Data, encoding: .utf8) {
                    let type = MyImageTypes.urlString(string)
                    myImageArray.append(type)
                }
            }
            return myImageArray
        }
        else {
            print("Unable to convert data to [MyImageTypes]")
            return nil
        }
    }
}

//                              NSKeyedUnarchiver.unarchiveObject(with: self) as? NSArray  이거 호출될 때 Data타입 내부적으로
//                              init(coder aDecoder:) - decoding 이 메소드가 호출
