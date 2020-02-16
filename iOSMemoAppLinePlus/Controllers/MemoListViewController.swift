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
        if DataManager.shared.memoList.isEmpty {
            DispatchQueue.main.async {
                self.showEmptyStateView(with: "메모가 없습니다.\n 새 메모를 만들어보세요!", in: self.view,
                                        imageName: EmptyStateViewImageName.list, superViewType: .memoList)
            }
        } else {
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
        token = NotificationCenter.default.addObserver(forName: CreateNewMemoViewController.newMemoCreated, object: nil,
                                                       queue: OperationQueue.main) { [weak self] (noti) in
            guard let self = self else{return}
            self.tableView.reloadData()
        }
    }
    
    @objc func didTapAddNewMemoButton() {
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

        navigationController?.pushViewController(memoDetailVC, animated: true)
    }
    
}
