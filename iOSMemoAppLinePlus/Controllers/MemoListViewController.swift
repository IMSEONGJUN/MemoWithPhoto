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
    lazy var searchBar = UISearchBar(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        configureTableView()
        setConstraints()
        setNotiToken()
        configureSearchBar()
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
        navigationController?.navigationBar.tintColor = MyColors.brown
        navigationController?.navigationBar.barTintColor = MyColors.barColor
        title = "SJMemo"
        let addNewMemoButton = UIBarButtonItem(barButtonSystemItem: .add, target: self,
                                               action: #selector(didTapAddNewMemoButton))
        navigationItem.rightBarButtonItem = addNewMemoButton
    }

    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 100
        tableView.register(MemoCell.self, forCellReuseIdentifier: MemoCell.identifier)
        tableView.backgroundColor = MyColors.content
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
    
    func configureSearchBar() {
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        searchBar.placeholder = "Search for Keyword"
        navigationItem.titleView = searchBar
        
    }
    
    @objc func didTapAddNewMemoButton() {
        DispatchQueue.main.async {
            if self.children.count > 0{
                self.children.forEach({ $0.willMove(toParent: nil); $0.view.removeFromSuperview(); $0.removeFromParent() })
            }
        }
        let createNewMemoVC = UINavigationController(rootViewController: CreateNewMemoViewController())
        createNewMemoVC.modalPresentationStyle = .fullScreen
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
        if isSearching {
            return DataManager.shared.filteredMemoList.count
        } else {
            return DataManager.shared.memoList.count
        }
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
        memoDetailVC.delegate = self
        memoDetailVC.memo = memo
        memoDetailVC.indexPath = indexPath
        memoDetailVC.isFilteredBefore = isSearching

        navigationController?.pushViewController(memoDetailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {return}
        self.searchBar.text?.removeAll()
        DataManager.shared.removeMemo(indexPath: indexPath, isInFilteredMemoList: isSearching)
//        var activeArray = isSearching ? DataManager.shared.filteredMemoList : DataManager.shared.memoList // 값의 복사가 일어난다 왜지??? // DataManager.shared 를 먼저 받았으면 레퍼런스 타입으로 전달되는데 DataManager.shared.memoList 로 받으면 값으로 들어간다.
//        let commit = activeArray[indexPath.row]
//        // Network Manager 에 removeMemo() 함수 만드는것이 좋다.
//        activeArray.remove(at: indexPath.row)
//
//        if isSearching {DataManager.shared.filteredMemoList.remove(at: indexPath.row)}
//        DataManager.shared.mainContext.delete(commit)
//        DataManager.shared.fetchMemo()
//        DataManager.shared.saveContext()
        tableView.deleteRows(at: [indexPath], with: .left)
        
        self.isSearching = false
        tableView.reloadData()
        
        
            
//        DispatchQueue.main.async {
//            tableView.reloadData()
//        }
        checkCoreDataEmpty()
    }
}

extension MemoListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("search")
        let filterKey = searchText
        guard !filterKey.isEmpty else {
            isSearching = false
            DataManager.shared.filteredMemoList.removeAll()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            return
        }
        DataManager.shared.filteredMemoList = DataManager.shared.memoList.filter({($0.title?.lowercased().contains(filterKey.lowercased()) ?? false) ||
            $0.content?.lowercased().contains(filterKey.lowercased()) ?? false })
        isSearching = true
        tableView.reloadData()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text?.removeAll()
        DataManager.shared.filteredMemoList.removeAll()
        isSearching = false
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
    }

}

extension MemoListViewController: MemoDetailViewControllerDelegate {
    func removeTableViewRow(indexPath: IndexPath, isSearching: Bool) {
        self.tableView.deleteRows(at: [indexPath], with: .left)
        self.isSearching = isSearching
        self.tableView.reloadData()
    }
    
    
}
//                let viewControllers:[UIViewController] = self.children
//                for viewContoller in viewControllers{
//                    viewContoller.willMove(toParent: nil)
//                    viewContoller.view.removeFromSuperview()
//                    viewContoller.removeFromParent()
//                }
