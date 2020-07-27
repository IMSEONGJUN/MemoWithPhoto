//
//  DataManager.swift
//  iOSMemoAppLinePlus
//
//  Created by SEONGJUN on 2020/02/13.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import Foundation
import CoreData

final class DataManager {
    
    static let shared = DataManager(isMock: false)
    static let mock = DataManager(isMock: true)
    
    private let isMock: Bool!
    
    private init(isMock: Bool) {
        self.isMock = isMock
    }
    
    
    var mainContext: NSManagedObjectContext{
        return persistentContainer.viewContext
    }
    
    var memoList = [Memo]() // 코어데이터 entity 의 타입네임과 같은 타입으로 이루어진 배열로 일명 'managed object'(관리객체)로서 메모리에서 변화가 있는 경우 persistentContainer.viewContext를 통해 이를 관리하고 저장한다.
    var filteredMemoList = [Memo]()
    
    func fetchMemo() {
        let request: NSFetchRequest<Memo> = Memo.fetchRequest()
        let sortByDateDesc = NSSortDescriptor(key: "recentlyEditedDate", ascending: false)
        request.sortDescriptors = [sortByDateDesc]
        
        do {                                           // 코어데이터의 entity 자체가 class이다. 즉 레퍼런스 타입이다.
            memoList = try mainContext.fetch(request) // fetch하면 반환타입은 코어데어터 entity타입중 request에 입력한 타입(NSFetchRequest<Memo>)
                                                        //(레퍼런스 타입)의 배열로 리턴된다.
                                                      // memoList 변수가 persistentContainer.viewContext로부터 Entity이름의(Memo) 레퍼런스타입
                                                    // 배열의 참조값을 갖게된다. 따라서 memoList 변수를 수정하는 것은 곧 동시에 persistentContainer.viewContext를 수정하게 되는 것이다.
        } catch {
            print(error)
        }
    }
    
    func editMemo(index: Int, title: String?, memo: String?, images: Data?, isEdited: Bool = true) {
        let memoToEdit = memoList[index]
        memoToEdit.title = title
        memoToEdit.content = memo
        memoToEdit.images = images
        memoToEdit.isEdited = isEdited //true 인 경우, 디테일 뷰에서 최근 수정 날짜(recentlyEditedDate)를 띄워주고 싶었음.
        memoToEdit.recentlyEditedDate = Date()
    
        memoList.remove(at: index)
        memoList.insert(memoToEdit, at: 0) // memoList를 수정하면 mainContext도 수정됨. 같은 레퍼런스 참조
        
        saveContext() // persistentContainer.viewContext(= mainContext)를 저장하는 것
        fetchMemo()
    }
    
    func removeMemo(indexPath: IndexPath, isInFilteredMemoList: Bool) {
        if isInFilteredMemoList {
            let commit = filteredMemoList[indexPath.row]
            filteredMemoList.remove(at: indexPath.row)
            mainContext.delete(commit)
        } else {
            let commit = memoList[indexPath.row]
            memoList.remove(at: indexPath.row)
            mainContext.delete(commit)
        }
        fetchMemo()
        saveContext()
    }
    
    func addNewMemo(title: String?, memo: String?, images: Data?, at index:Int = 0) {
        let newMemo = Memo(context: mainContext)
        newMemo.title = title
        newMemo.content = memo
        newMemo.images = images
        newMemo.isEdited = false
        newMemo.createdDate = Date()
        newMemo.recentlyEditedDate = Date()
        
        memoList.insert(newMemo, at: index)
        
        saveContext()
        fetchMemo()
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "LinePlusMemo")
        if isMock {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            description.shouldAddStoreAsynchronously = false
            container.persistentStoreDescriptions = [description]
        }
        // 저장된 데이터 베이스가 있는 경우 이를 로드하며, 없는 경우 저장할 데이터베이스를 만든다.
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func deleteAllRecords() {
        
        let context = persistentContainer.viewContext
        
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Memo")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    func flushData() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Memo")
        let objs = try! persistentContainer.viewContext.fetch(fetchRequest)
        for case let obj as NSManagedObject in objs {
            persistentContainer.viewContext.delete(obj)
        }
        try! persistentContainer.viewContext.save()
    }
}
