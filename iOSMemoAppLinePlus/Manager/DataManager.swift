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
    
    static let shared = DataManager()
    private init() {}
    
    var mainContext: NSManagedObjectContext{
        return persistentContainer.viewContext
    }
    
    var memoList = [Memo]()
    var filteredMemoList = [Memo]()
    
    func fetchMemo() {
        let request: NSFetchRequest<Memo> = Memo.fetchRequest()
        let sortByDateDesc = NSSortDescriptor(key: "recentlyEditedDate", ascending: false)
        request.sortDescriptors = [sortByDateDesc]
        
        do {
            memoList = try mainContext.fetch(request)
        } catch {
            print(error)
        }
    }
    
    func editMemo(index: Int, title: String?, memo: String?, images: Data?, isEdited: Bool = true) {
        let memoToEdit = memoList[index]
        memoToEdit.title = title
        memoToEdit.content = memo
        memoToEdit.images = images
        memoToEdit.isEdited = isEdited
        memoToEdit.recentlyEditedDate = Date()
        
        memoList.remove(at: index)
        memoList.insert(memoToEdit, at: 0)
        
        saveContext()
        fetchMemo()
    }
    
    func removeMemo(indexPath: IndexPath, isInFilteredMemoList: Bool) {
        if isInFilteredMemoList {
            let commit = filteredMemoList[indexPath.row]
            mainContext.delete(commit)
            filteredMemoList.remove(at: indexPath.row)
        } else {
            let commit = memoList[indexPath.row]
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
}
