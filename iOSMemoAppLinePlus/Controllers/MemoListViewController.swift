//
//  MemoListViewController.swift
//  iOSMemoAppLinePlus
//
//  Created by SEONGJUN on 2020/02/13.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import UIKit

class MemoListViewController: UIViewController {

    fileprivate let tableView = UITableView()
    
    var token: NSObjectProtocol?
    var isSearching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        configureTableView()
        setConstraints()
        setNotiToken()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DataManager.shared.fetchMemo()
        checkCoreDataEmpty()
    }
    
    func checkCoreDataEmpty() {
        if DataManager.shared.memoList.isEmpty {
            DispatchQueue.main.async {
                self.showEmptyStateView(with: "메모가 없습니다.\n 새 메모를 만들어보세요!", in: self.view,
                                        imageName: EmptyStateViewImageName.list, superViewType: .memoList)
            }
        } else {
            if self.children.count > 0{
                self.children.forEach({ $0.willMove(toParent: nil); $0.view.removeFromSuperview(); $0.removeFromParent() })
            }
            tableView.reloadData()
        }
    }
    
    private func setupNavigationBar() {
        view.backgroundColor = .white
        title = "SJMemo"
        let addNewMemoButton = UIBarButtonItem(barButtonSystemItem: .add, target: self,
                                               action: #selector(didTapAddNewMemoButton))
        navigationItem.rightBarButtonItem = addNewMemoButton
    }

    private func configureTableView() {
        tableView.dataSource = self
        tableView.rowHeight = 100
        tableView.register(MemoCell.self, forCellReuseIdentifier: MemoCell.identifier)
        tableView.delegate = self
        tableView.tableFooterView = UIView(frame: .zero)
        view.addSubview(tableView)
    }
    
    private func setConstraints() {
        tableView.pin(to: view)
    }
    
    private func setNotiToken() {
        token = NotificationCenter.default.addObserver(
            forName: CreateNewMemoViewController.newMemoCreated,
            object: nil,
            queue: OperationQueue.main) { [weak self] (noti) in
            guard let self = self else{return}
            self.tableView.reloadData()
        }
    }
    
    @objc func didTapAddNewMemoButton() {
        DispatchQueue.main.async {
            if self.children.count > 0{
                self.children.forEach({ $0.willMove(toParent: nil); $0.view.removeFromSuperview(); $0.removeFromParent() })
            }
        }
        let createNewMemoVC = UINavigationController(rootViewController: CreateNewMemoViewController())
        present(createNewMemoVC, animated: true)
    }
    
    deinit{
        if let token = token {
            NotificationCenter.default.removeObserver(token)
        }
    }

}


extension MemoListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataManager.shared.memoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MemoCell.identifier, for: indexPath) as! MemoCell
        if !isSearching {
            cell.set(memo: DataManager.shared.memoList[indexPath.row])
        } else {
            cell.set(memo: DataManager.shared.filteredMemoList[indexPath.row])
        }
        return cell
    }
    
    
}

extension MemoListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let activeArray = isSearching ? DataManager.shared.filteredMemoList : DataManager.shared.memoList
        let memo = activeArray[indexPath.row]
        let memoDetailVC = MemoDetailViewController()
        memoDetailVC.memo = memo
        memoDetailVC.indexPath = indexPath
        memoDetailVC.isFilteredBefore = isSearching

        navigationController?.pushViewController(memoDetailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {return}
        var activeArray = isSearching ? DataManager.shared.filteredMemoList : DataManager.shared.memoList
        if isSearching {
            let memoDateForRemove = DataManager.shared.filteredMemoList[indexPath.row].createdDate
            if let index = DataManager.shared.memoList.firstIndex(where: {$0.createdDate == memoDateForRemove}) {
                let commit = DataManager.shared.memoList[index]
                DataManager.shared.mainContext.delete(commit)
//                DataManager.shared.memoList.remove(at: index)
                activeArray.remove(at: activeArray.firstIndex(of: activeArray[index])!)
            }
        } else {
            let commit = activeArray[indexPath.row]
            DataManager.shared.mainContext.delete(commit)
            DataManager.shared.fetchMemo()
            DataManager.shared.saveContext()
            
            tableView.deleteRows(at: [indexPath], with: .left)
            
            
//            let commit = activeArray[indexPath.row]
//            DataManager.shared.mainContext.delete(commit)
//            activeArray.remove(at: activeArray.firstIndex(of: activeArray[indexPath.row])!)
        }
//        DataManager.shared.saveContext()
        
        
//        DataManager.shared.fetchMemo()
        DispatchQueue.main.async {
            tableView.reloadData()
        }
        checkCoreDataEmpty()
    }
}


//                let viewControllers:[UIViewController] = self.children
//                for viewContoller in viewControllers{
//                    viewContoller.willMove(toParent: nil)
//                    viewContoller.view.removeFromSuperview()
//                    viewContoller.removeFromParent()
//                }
