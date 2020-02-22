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
    
    let validUrlForTest = "https://d.line-scdn.net/stf/line-lp/ko_2016_01.png"
    let invalidUrlForTest = "https://line.me/ko/abc"
    
    override func setUp() {
        testImages = ["01","02","03","04","05","06","07","08","09","10"].map({ UIImage(named: $0)!})
        myImageTypesArray = testImages.map { MyImageTypes.image($0) }
        DataManager.shared.deleteAllRecords()
        DataManager.shared.fetchMemo()
    }
    
    override func tearDown() {
        myImageTypesArray?.removeAll()
        DataManager.shared.deleteAllRecords()
        DataManager.shared.fetchMemo()
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
    
    func testDownloadImageFromValidURL() {
        let imageView = UIImageView()
        let promise = expectation(description:"network test")
        NetworkManager.shared.downloadImage(from: validUrlForTest) {(result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let image):
                    imageView.image = image
                case .failure(let error):
                    print(error.rawValue)
                }
                XCTAssertNotNil(imageView.image)
                promise.fulfill()
            }
        }
                
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testDownloadImageFromInvalidURL() {
        let imageView = UIImageView()
        let promise = expectation(description:"network test")
        NetworkManager.shared.downloadImage(from: invalidUrlForTest) {(result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let image):
                    imageView.image = image
                case .failure(let error):
                    print(error.rawValue)
                }
                XCTAssertNil(imageView.image)
                promise.fulfill()
            }
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testCoreDataCredibilityCheck() {
        var testMemoList = [Memo]()
        
        let title = "메모 제목"
        let content = "메모 내용"
        
        DataManager.shared.addNewMemo(title: title, memo: content, images: nil)
        testMemoList = DataManager.shared.memoList
        
        XCTAssertTrue(testMemoList.first?.title == title)
        XCTAssertTrue(testMemoList.first?.content == content)
    }
    
    func testCompareInputMemoCountAndOutputMemoCount() {
        let count = 5
        let myImageTypeValue = [MyImageTypes.image(UIImage(named: "01")!)]
        
        for i in 0..<count {
            DataManager.shared.addNewMemo(title: "\(i)",
                                          memo: "\(i)",
                                          images: myImageTypeValue.convertToCoreDataRepresentation())
        }
        var testMemoList = [Memo]()
        testMemoList = DataManager.shared.memoList
        XCTAssertTrue(testMemoList.count == count)
    }
    
    func testInputFiveMemoAndDeleteTwoMemoThenResult(){
        let inputCount = 5
        let deleteCount = 2
        let outputCount = 3
        
        let myImageTypeValue = [MyImageTypes.image(UIImage(named: "01")!)]
        
        for i in 0..<inputCount {
            DataManager.shared.addNewMemo(title: "\(i)",
                                          memo: "\(i)",
                                          images: myImageTypeValue.convertToCoreDataRepresentation())
        }
        for i in 0..<deleteCount {
            DataManager.shared.removeMemo(indexPath: IndexPath(row: i, section: 0), isInFilteredMemoList: false)
        }
        
        var testMemoList = [Memo]()
        testMemoList = DataManager.shared.memoList
        XCTAssertTrue(testMemoList.count == outputCount)
    }
    
    func testEditMemoTitleAndContent() {
        
        // Before Edited
        let title = "programmer"
        let content = "nice and good"
        
        DataManager.shared.addNewMemo(title: title,
                                      memo: content,
                                      images: nil, at: 0)
        
        var testMemoList = [Memo]()
        testMemoList = DataManager.shared.memoList
        
        XCTAssertTrue(testMemoList.first?.title == title)
        XCTAssertTrue(testMemoList.first?.content == content)
        XCTAssertNil(testMemoList.first?.images)
        
        // After Edited
        let editedTitle = "iOS programmer"
        let editedContent = "amazing and awesome"
        let editedMyImageTypeValue = [MyImageTypes.image(UIImage(named: "02")!)]
        
        DataManager.shared.editMemo(index: 0,
                                    title: editedTitle,
                                    memo: editedContent,
                                    images: editedMyImageTypeValue.convertToCoreDataRepresentation())
        
        var testEditedMemoList = [Memo]()
        testEditedMemoList = DataManager.shared.memoList
        
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

