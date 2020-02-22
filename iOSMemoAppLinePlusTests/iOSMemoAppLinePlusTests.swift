//
//  iOSMemoAppLinePlusTests.swift
//  iOSMemoAppLinePlusTests
//
//  Created by SEONGJUN on 2020/02/22.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import XCTest
@testable import iOSMemoAppLinePlus


class iOSMemoAppLinePlusTests: XCTestCase {
    let typeCompareData: Data? = Data()
    let typeCompareMyImage: [MyImageTypes]? = []
    var testImages = [UIImage]()
    
    var myImageTypesArray: [MyImageTypes]? = []
    var coreDataRepresentation: Data?
    
    override func setUp() {
        testImages = ["01","02","03","04","05","06","07","08","09","10"].map({ UIImage(named: $0)!})
        myImageTypesArray = testImages.map {MyImageTypes.image($0)}
        
    }
    
    override func tearDown() {
        myImageTypesArray?.removeAll()
    }

    func testConvertMyImageTypeArrayToDataTypeAndInverseCase() {
        print(myImageTypesArray!.count) // 10개
        coreDataRepresentation = myImageTypesArray?.convertToCoreDataRepresentation() // convert to Data?
    
        XCTAssertNotNil(coreDataRepresentation)
        XCTAssertTrue(type(of: coreDataRepresentation) == type(of: typeCompareData))
        
        myImageTypesArray = coreDataRepresentation?.convertToMyImageTypeArray() // convert to [MyImageType]?
        XCTAssertNotNil(myImageTypesArray)
        XCTAssertTrue(type(of: myImageTypesArray) == type(of: typeCompareMyImage))
        XCTAssertTrue(myImageTypesArray?.count == 10)
        
    }

    func testConvert() {
       XCTAssertTrue(1 == 1)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}

