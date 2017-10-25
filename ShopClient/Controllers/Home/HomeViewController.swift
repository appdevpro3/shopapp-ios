//
//  HomeViewController.swift
//  ShopClient
//
//  Created by Evgeniy Antonov on 9/14/17.
//  Copyright © 2017 Evgeniy Antonov. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, HomeTableDataSourceProtocol, HomeTableDelegateProtocol, LastArrivalsCellDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    var dataSource: HomeTableDataSource?
    var delegate: HomeTableDelegate?
    
    var lastArrivalsProducts = [Product]()
    var newInBlogArticles = [Article]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTitle()
        setupSideMenu()
        addMenuBarButton()
        addSearchButton()
        setupTableView()
        loadRemoteData()
    }
    
    private func setupTitle() {
        title = NSLocalizedString("ControllerTitle.Home", comment: String())
    }
    
    private func setupTableView() {
        let lastArrivalsNib = UINib(nibName: String(describing: LastArrivalsTableViewCell.self), bundle: nil)
        tableView.register(lastArrivalsNib, forCellReuseIdentifier: String(describing: LastArrivalsTableViewCell.self))
        
        let newInBlogNib = UINib(nibName: String(describing: ArticleTableViewCell.self), bundle: nil)
        tableView.register(newInBlogNib, forCellReuseIdentifier: String(describing: ArticleTableViewCell.self))
        
        let newInBlogLoadMoreNib = UINib(nibName: String(describing: ArticleLoadMoreCell.self), bundle: nil)
        tableView.register(newInBlogLoadMoreNib, forCellReuseIdentifier: String(describing: ArticleLoadMoreCell.self))
        
        dataSource = HomeTableDataSource(delegate: self)
        tableView.dataSource = dataSource
        
        delegate = HomeTableDelegate(delegate: self)
        tableView.delegate = delegate
    }
    
    private func addSearchButton() {
        let searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(HomeViewController.seachButtonHandler))
        navigationItem.rightBarButtonItem = searchButton
    }
    
    @objc private func seachButtonHandler() {
        pushSearchController()
    }
    
    private func loadRemoteData() {
        RepositoryRepo.shared.getProductList(sortBy: SortingValue.createdAt, reverse: true) { [weak self] (products, error) in
            if let items = products {
                self?.lastArrivalsProducts = items
                self?.loadArticles()
                self?.tableView.reloadSections([0], with: .none)
            }
        }
    }
    
    private func loadArticles() {
        RepositoryRepo.shared.getArticleList(reverse: true) { [weak self] (result, error) in
            if let articles = result {
                self?.newInBlogArticles = articles
                self?.tableView.reloadData()
            }
        }
    }
    
    // MARK: - override
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        tableView.reloadData()
    }
    
    // MARK: - HomeTableDataSourceProtocol
    func lastArrivalsObjects() -> [Product] {
        return lastArrivalsProducts
    }
    
    func didSelectProduct(at index: Int) {
        if index < lastArrivalsProducts.count {
            let selectedProduct = lastArrivalsProducts[index]
            pushDetailController(with: selectedProduct)
        }
    }
    
    func articlesCount() -> Int {
        return newInBlogArticles.count
    }
    
    func article(at index: Int) -> Article? {
        if index < newInBlogArticles.count {
            return newInBlogArticles[index]
        }
        return nil
    }
    
    // MARK: - HomeTableDelegateProtocol
    func didSelectArticle(at index: Int) {
        if index < newInBlogArticles.count {
            let article = newInBlogArticles[index]
            pushArticleDetailsController(with: article)
        }
    }
    
    func didTapLoadMore() {
        pushArticlesListController()
    }
    
    // MARK: - LastArrivalsCellDelegate
    func didTapLastArrivalsLoadMore() {
        pushLastArrivalsController()
    }
}
