//
//  DataManager.swift
//  iOSMemoAppLinePlus
//
//  Created by SEONGJUN on 2020/02/13.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import Foundation
import CoreData

class DataManager {
    
    static let shared = DataManager()
    private init() {
        
    }
    
    var mainContext: NSManagedObjectContext{
        return persistentContainer.viewContext
    }
    
    var memoList = [Memo]()
    var filteredMemoList = [Memo]()
    
    func fetchMemo() {
        let request: NSFetchRequest<Memo> = Memo.fetchRequest()
        
        let sortByDateDesc = NSSortDescriptor(key: "createdDate", ascending: false)
        request.sortDescriptors = [sortByDateDesc]
        
        do{
            memoList = try mainContext.fetch(request)
        }catch{
            print(error)
        }
        
    }
    
    func addNewMemo(title: String?, memo: String?, images: Data?) {
        let newMemo = Memo(context: mainContext)
        newMemo.title = title
        newMemo.content = memo
        newMemo.images = images
        newMemo.isEdited = false
        newMemo.createdDate = Date()
        newMemo.recentlyModifyDate = nil
        
        memoList.insert(newMemo, at: 0)
        
        saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
         
          let container = NSPersistentContainer(name: "SJMemo")
          container.loadPersistentStores(completionHandler: { (storeDescription, error) in
              if let error = error as NSError? {
            
                  fatalError("Unresolved error \(error), \(error.userInfo)")
              }
          })
          return container
      }()

      // MARK: - Core Data Saving support

      func saveContext () {
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
}
