//
//  MemoListViewController.swift
//  iOSMemoAppLinePlus
//
//  Created by SEONGJUN on 2020/02/13.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import UIKit

class MemoListViewController: UIViewController {
    
    // MARK: Properties
    fileprivate let tableView = UITableView()
    
    var token: NSObjectProtocol?
    var isSearching = false
    lazy var searchBar = UISearchBar(frame: .zero)
    let addbutton = UIButton()
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        configureTableView()
        configureAddNewMemoButtonOnBottomSide()
        setConstraints()
        setNotiToken()
        configureSearchBar()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DataManager.shared.fetchMemo()
        checkCoreDataEmpty()
    }
    
    deinit{
        if let token = token {
            NotificationCenter.default.removeObserver(token)
        }
    }
    
    
    // MARK: - Setup
    
    func checkCoreDataEmpty() {
        if DataManager.shared.memoList.isEmpty {
            self.showEmptyStateView(with: TextMessages.noMemos, in: self.view,
                                    imageName: EmptyStateViewImageName.list, superViewType: .memoList)
        } else {
            checkSelfHaveChildrenVC(on: self)
            tableView.reloadData()
        }
    }
    
    private func setupNavigationBar() {
        view.backgroundColor = .white
        navigationController?.navigationBar.tintColor = MyColors.brown
        navigationController?.navigationBar.barTintColor = MyColors.barColor
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
        addbutton.snp.makeConstraints {
            $0.bottom.trailing.equalToSuperview().inset(50)
            $0.width.height.equalTo(50)
        }
    }
    
    private func setNotiToken() {
        token = NotificationCenter.default.addObserver( // 이 메소드의 반환값의 타입은 NSObjectProtocol 타입이다.
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
        searchBar.placeholder = ButtonNames.search
        navigationItem.titleView = searchBar
    }
    
    func configureAddNewMemoButtonOnBottomSide() {
        addbutton.setImage(#imageLiteral(resourceName: "plus"), for: .normal)
        addbutton.imageView?.contentMode = .scaleAspectFill
        addbutton.imageView?.clipsToBounds = true
        addbutton.addTarget(self, action: #selector(didTapAddNewMemoButton), for: .touchUpInside)
        view.addSubview(addbutton)
        view.bringSubviewToFront(addbutton)
    }
    
    // MARK: - Action Handle
    
    @objc func didTapAddNewMemoButton() {
        self.checkSelfHaveChildrenVC(on: self)
        let createNewMemoVC = UINavigationController(rootViewController: CreateNewMemoViewController())
        createNewMemoVC.modalPresentationStyle = .fullScreen
        present(createNewMemoVC, animated: true)
    }
}


    // MARK: - UITableViewDataSource

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

    
    // MARK: - UITableViewDelegate

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
        tableView.deleteRows(at: [indexPath], with: .left)
        
        self.isSearching = false
        tableView.reloadData()

        checkCoreDataEmpty()
    }
}


    // MARK: - UISearchBarDelegate

extension MemoListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let filterKey = searchText
        guard !filterKey.isEmpty else {
            isSearching = false
            DataManager.shared.filteredMemoList.removeAll()
            self.tableView.reloadData()
            return
        }
        DataManager.shared.filteredMemoList = DataManager.shared.memoList.filter({
            $0.title?.lowercased().contains(filterKey.lowercased()) ?? false ||
            $0.content?.lowercased().contains(filterKey.lowercased()) ?? false
        })
        isSearching = true
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text?.removeAll()
        DataManager.shared.filteredMemoList.removeAll()
        isSearching = false
        self.tableView.reloadData()
    }
}


    // MARK: - MemoDetailViewControllerDelegate

extension MemoListViewController: MemoDetailViewControllerDelegate {
    func removeTableViewRow(indexPath: IndexPath, isSearching: Bool) {
        self.tableView.deleteRows(at: [indexPath], with: .left)
        self.isSearching = isSearching
        self.tableView.reloadData()
        self.searchBar.text?.removeAll()
        self.searchBar.resignFirstResponder()
    }
}

