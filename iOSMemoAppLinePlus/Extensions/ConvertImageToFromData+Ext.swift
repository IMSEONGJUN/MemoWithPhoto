//
//  Array+Ext.swift
//  iOSMemoAppLinePlus
//
//  Created by SEONGJUN on 2020/02/14.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import UIKit

extension Array where Element == MyImageTypes {
    
    func convertToCoreDataRepresentation() -> Data? {
        let CDataArray = NSMutableArray()

        for img in self {
            switch img {
            case .image(let val):
                guard let imageRepresentation = val.jpegData(compressionQuality: 0.5) else {
                    print("Unable to represent image as JPEG")
                    return nil
                }
                let nsdata : NSData = NSData(data: imageRepresentation)
                CDataArray.add(nsdata)
            
            case .urlString(let val):
                let data = Data(val.utf8)
                let nsdata : NSData = NSData(data: data)
                CDataArray.add(nsdata)
            }
        }
        return NSKeyedArchiver.archivedData(withRootObject: CDataArray)
    }
}

extension Data {

    func convertToMyImageTypeArray() -> [MyImageTypes]? {
        var myImageArray = [MyImageTypes]()
        
        if let mySavedData = NSKeyedUnarchiver.unarchiveObject(with: self) as? NSArray {
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
            print("Unable to convert data to ImageArray")
            return nil
        }
    }
}


//            let imgArray = mySavedData.compactMap({
//                return UIImage(data: $0 as! Data)
//            })
//            return imgArray
