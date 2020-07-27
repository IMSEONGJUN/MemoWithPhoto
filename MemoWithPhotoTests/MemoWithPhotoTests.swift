//
//  iOSMemoAppLinePlusTests.swift
//  iOSMemoAppLinePlusTests
//
//  Created by SEONGJUN on 2020/02/22.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import XCTest
@testable import MemoWithPhoto


class MemoWithPhotoTests: XCTestCase {
    let typeCompareData: Data? = Data()
    let typeCompareMyImage: [MyImageTypes]? = []
    var testImages = [UIImage]()
    
    var myImageTypesArray: [MyImageTypes]? = []
    var coreDataRepresentation: Data?
    
    let validUrlForTest = "https://d.line-scdn.net/stf/line-lp/ko_2016_01.png"
    let invalidUrlForTest = "https://line.me/ko/abc"
    
    override func setUp() {
        testImages = ["01","02","03","04","05","06","07","08","09","10"].map({ UIImage(named: $0)!})
        myImageTypesArray = testImages.map { MyImageTypes.image($0) }
    }
    
    override func tearDown() {
        myImageTypesArray?.removeAll()
    }
    
    func clearData() {
        DataManager.mock.flushData()
    }

    func testConvertMyImageTypeArrayToDataTypeAndInverseCase() {
        print(myImageTypesArray!.count) // 10개
        coreDataRepresentation = myImageTypesArray?.convertToDataType() // convert to Data?
    
        XCTAssertNotNil(coreDataRepresentation)
        XCTAssertTrue(type(of: coreDataRepresentation) == type(of: typeCompareData))
        
        myImageTypesArray = coreDataRepresentation?.convertToMyImageTypeArray() // convert to [MyImageType]?
        XCTAssertNotNil(myImageTypesArray)
        XCTAssertTrue(type(of: myImageTypesArray) == type(of: typeCompareMyImage))
        XCTAssertTrue(myImageTypesArray?.count == 10)
    }
    
    func testDownloadImageFromValidURL() {
        let imageView = UIImageView()
        
//        let promise = expectation(description:"network test")
        let semaphore = DispatchSemaphore(value: 0)
        NetworkManager.shared.downloadImage(from: validUrlForTest) {(result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let image):
                    imageView.image = image
                    print("success")
                    XCTAssertNotNil(imageView.image)
                case .failure(let error):
                    print(error.rawValue)
                    XCTAssertNil(imageView.image)
                }
                
//                promise.fulfill()
                print("before break lock")
                semaphore.signal()
//                promise.fulfill()
            }
            semaphore.wait()
            print("break lock")
        }
             
//        waitForExpectations(timeout: 5, handler: nil)
//        print("break wait")
    }
    
    func testDownloadImageFromInvalidURL() {
        let imageView = UIImageView()
        let promise = expectation(description:"network test")
        NetworkManager.shared.downloadImage(from: invalidUrlForTest) {(result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let image):
                    imageView.image = image
                    XCTAssertNotNil(imageView.image)
                case .failure(let error):
                    print(error.rawValue)
                    XCTAssertNil(imageView.image)
                }
                promise.fulfill()
            }
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testCoreDataCredibilityCheck() {
        clearData()
        
        var testMemoList = [Memo]()
        
        let title = "메모 제목"
        let content = "메모 내용"
        
        DataManager.mock.addNewMemo(title: title, memo: content, images: nil)
        testMemoList = DataManager.mock.memoList
        
        XCTAssertTrue(testMemoList.first?.title == title)
        XCTAssertTrue(testMemoList.first?.content == content)
    }
    
    func testCompareInputMemoCountAndOutputMemoCount() {
        clearData()
        let count = 5
        let myImageTypeValue = [MyImageTypes.image(UIImage(named: "01")!)]
        
        for i in 0..<count {
            DataManager.mock.addNewMemo(title: "\(i)",
                                          memo: "\(i)",
                                          images: myImageTypeValue.convertToDataType())
        }
        var testMemoList = [Memo]()
        testMemoList = DataManager.mock.memoList
        XCTAssertTrue(testMemoList.count == count)
    }
    
    func testInputFiveMemoAndDeleteTwoMemoThenResult() {
        clearData()
        let inputCount = 5
        let deleteCount = 2
        let outputCount = 3
        
        let myImageTypeValue = [MyImageTypes.image(UIImage(named: "01")!)]
        
        for i in 0..<inputCount {
            DataManager.mock.addNewMemo(title: "\(i)",
                                          memo: "\(i)",
                                          images: myImageTypeValue.convertToDataType())
        }
        for i in 0..<deleteCount {
            DataManager.mock.removeMemo(indexPath: IndexPath(row: i, section: 0), isInFilteredMemoList: false)
        }
        
        var testMemoList = [Memo]()
        testMemoList = DataManager.mock.memoList
        XCTAssertTrue(testMemoList.count == outputCount)
    }
    
    func testEditMemoTitleAndContent() {
        clearData()
        
        // Before Edited
        let title = "programmer"
        let content = "nice and good"
        
        DataManager.mock.addNewMemo(title: title,
                                      memo: content,
                                      images: nil, at: 0)
        
        var testMemoList = [Memo]()
        testMemoList = DataManager.mock.memoList
        
        XCTAssertTrue(testMemoList.first?.title == title)
        XCTAssertTrue(testMemoList.first?.content == content)
        XCTAssertNil(testMemoList.first?.images)
        
        // After Edited
        let editedTitle = "iOS programmer"
        let editedContent = "amazing and awesome"
        let editedMyImageTypeValue = [MyImageTypes.image(UIImage(named: "02")!)]
        
        DataManager.mock.editMemo(index: 0,
                                    title: editedTitle,
                                    memo: editedContent,
                                    images: editedMyImageTypeValue.convertToDataType())
        
        var testEditedMemoList = [Memo]()
        testEditedMemoList = DataManager.mock.memoList
        
        XCTAssertTrue(testEditedMemoList.first?.title == editedTitle)
        XCTAssertTrue(testEditedMemoList.first?.content == editedContent)
        XCTAssertNotNil(testEditedMemoList.first?.images)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}

