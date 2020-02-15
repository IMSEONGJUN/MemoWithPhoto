//
//  Array+Ext.swift
//  iOSMemoAppLinePlus
//
//  Created by SEONGJUN on 2020/02/14.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import UIKit

extension Array where Element: UIImage {
    // Given an array of UIImages return a Data representation of the array suitable for storing in core data as binary data that allows external storage
    func coreDataRepresentation() -> Data? {
        let CDataArray = NSMutableArray()

        for img in self {
            guard let imageRepresentation = img.jpegData(compressionQuality: 0.5) else {
                print("Unable to represent image as JPEG")
                return nil
            }
            let data : NSData = NSData(data: imageRepresentation)
            CDataArray.add(data)
        }

        return NSKeyedArchiver.archivedData(withRootObject: CDataArray)
    }
}

extension Data {

    func imageArray() -> [UIImage]? {
        if let mySavedData = NSKeyedUnarchiver.unarchiveObject(with: self) as? NSArray {
            // TODO: Use regular map and return nil if something can't be turned into a UIImage
            let imgArray = mySavedData.compactMap({
                return UIImage(data: $0 as! Data)
            })
            return imgArray
        }
        else {
            print("Unable to convert data to ImageArray")
            return nil
        }
    }
}
