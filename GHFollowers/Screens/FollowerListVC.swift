//
//  FollowerListVC.swift
//  GHFollowers
//
//  Created by Леонид Кузнецов on 15.03.2020.
//  Copyright © 2020 Leonid Kuznetcov. All rights reserved.
//

import UIKit

class FollowerListVC: GFDataLoadingVC {
    
    enum Section { case main }
    
    var username: String!
    var followers: [Follower]           = []
    var filteredFollowers: [Follower]   = []
    var page                            = 1
    var hasMoreFollowers                = true
    var isSearching                     = false
    var isLoadingMoreFollowers          = false
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, Follower>!
    let searchController = UISearchController()
    
    
    init(username: String) {
        super.init(nibName: nil, bundle: nil)
        self.username   = username
        title           = username
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        configureSearchController()
        configureCollectionView()
        getFollowers(username: username, page: page)
        configureDataSource()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    
    func configureViewController() {
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let addButton = UIBarButtonItem(title: "Add to Favorites", style: .plain, target: self, action: #selector(addButtonTapped))
        navigationItem.rightBarButtonItem = addButton
    }
    
    
    func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UIHelper.createThreeColumnFlowLayout(in: view))
        view.addSubview(collectionView)
        collectionView.delegate         = self
        collectionView.backgroundColor  = .systemBackground
        collectionView.register(FollowerCell.self, forCellWithReuseIdentifier: FollowerCell.reuseID)
    }
    
    
    func configureSearchController() {
        searchController.searchResultsUpdater                   = self
        searchController.searchBar.placeholder                  = "Search for a username"
        searchController.obscuresBackgroundDuringPresentation   = false
        
        navigationItem.searchController                         = searchController
        navigationItem.hidesSearchBarWhenScrolling              = false
    }
    
    
    func getFollowers(username: String, page: Int) {
        showLoadingView()
        isLoadingMoreFollowers = true
        
        NetworkManager.shared.getFollowers(for: username, page: page) { [weak self] (result) in
            guard let self = self else { return }
            self.dismissLoadingView()
            
            switch result {
            case .success(let followers):
                self.updateUI(with: followers)
                
            case .failure(let error):
                self.presentGFAlertOnMainThread(title: "Bad Stuff Happened", message: error.rawValue, buttonTitle: "Ok")
            }
            
            self.isLoadingMoreFollowers = false
        }
    }
    
    
    func updateUI(with followers: [Follower]) {
        if followers.count < 100 { self.hasMoreFollowers = false }
        self.followers.append(contentsOf: followers)
        
        if self.followers.isEmpty {
            let message = "This user doesn't have any followers. Go follow them 😀."
            DispatchQueue.main.async { self.showEmptyStateView(with: message, in: self.view) }
            return
        }
        
        self.updateData(on: self.followers)
        DispatchQueue.main.async { self.updateSearchResults(for: self.searchController) }
    }
    
    
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Follower>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, follower) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FollowerCell.reuseID, for: indexPath) as! FollowerCell
            cell.set(follower: follower)
            return cell
        })
    }
    
    
    func updateData(on followers: [Follower]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Follower>()
        snapshot.appendSections([.main])
        snapshot.appendItems(followers)
        DispatchQueue.main.async { self.dataSource.apply(snapshot, animatingDifferences: true) }
    }
    
    
    @objc func addButtonTapped() {
        showLoadingView()
        
        NetworkManager.shared.getUserInfo(for: username) { [weak self] (result) in
            guard let self = self else { return }
            self.dismissLoadingView()
            
            switch result {
            case .success(let user):
                self.addUserToFavorites(user: user)
                
            case .failure(let error):
                self.presentGFAlertOnMainThread(title: "Something went wrong!", message: error.rawValue, buttonTitle: "Ok")
            }
        }
    }
    
    
    func addUserToFavorites(user: User) {
        let follower = Follower(login: user.login, avatarUrl: user.avatarUrl)
        
        PersistenceManager.updateWith(favorite: follower, actionType: .add) { [weak self] (error) in
            guard let self = self else { return }
            
            guard let error = error else {
                self.presentGFAlertOnMainThread(title: "Success!", message: "User is added to favorites.", buttonTitle: "Nice!")
                return
            }
            
            self.presentGFAlertOnMainThread(title: "Something went wrong!", message: error.rawValue, buttonTitle: "Ok")
        }
    }
}


//MARK: - UICollectionViewDelegate Methods

extension FollowerListVC: UICollectionViewDelegate {
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY         = scrollView.contentOffset.y
        let contentHeight   = scrollView.contentSize.height
        let height          = scrollView.frame.size.height
        
        if offsetY > contentHeight - height {
            guard hasMoreFollowers, !isLoadingMoreFollowers else { return }
            page += 1
            getFollowers(username: username, page: page)
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let activeArray     = isSearching ? filteredFollowers : followers
        let follower        = activeArray[indexPath.item]
        
        let destVC          = UserInfoVC()
        destVC.username     = follower.login
        destVC.delegate     = self
        let navController   = UINavigationController(rootViewController: destVC)
        present(navController, animated: true)
    }
}


//MARK: - UISearchBar Methods

extension FollowerListVC: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let filter = searchController.searchBar.text, !filter.isEmpty else {
            isSearching = false
            filteredFollowers.removeAll()
            updateData(on: followers)
            return
        }
        
        isSearching = true
        filteredFollowers = followers.filter { $0.login.lowercased().contains(filter.lowercased()) }
        updateData(on: filteredFollowers)
    }
}


//MARK: - UserInfoVCDelegate Methods

extension FollowerListVC: UserInfoVCDelegate {
    
    func didRequestFollowers(for username: String) {
        self.username       = username
        title               = username
        page                = 1
        hasMoreFollowers    = true
        
        followers.removeAll()
        filteredFollowers.removeAll()
//        collectionView.setContentOffset(.zero, animated: true)
        collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        
        if isSearching {
            navigationItem.searchController?.searchBar.text = ""
            navigationItem.searchController?.isActive       = false
            navigationItem.searchController?.dismiss(animated: false)
            
            isSearching = false
        }
        
        getFollowers(username: username, page: page)
    }
}
