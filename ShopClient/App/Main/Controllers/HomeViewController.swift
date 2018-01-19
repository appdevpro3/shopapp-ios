//
//  HomeViewController.swift
//  ShopClient
//
//  Created by Evgeniy Antonov on 9/14/17.
//  Copyright © 2017 Evgeniy Antonov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class HomeViewController: BaseTableViewController<HomeViewModel>, HomeTableDataSourceProtocol, HomeTableDelegateProtocol, LastArrivalsCellDelegate, PopularCellDelegate, SeeAllHeaderViewProtocol {
    private var dataSource: HomeTableDataSource!
    // swiftlint:disable weak_delegate
    private var delegate: HomeTableDelegate!
    // swiftlint:enable weak_delegate
    private var destinationTitle: String!
    private var sortingValue: SortingValue!
    private var selectedProduct: Product?
    private var selectedArticle: Article?
    
    override func viewDidLoad() {
        viewModel = HomeViewModel()
        super.viewDidLoad()
        
        setupTableView()
        setupViewModel()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateNavigationBar()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let productsListViewController = segue.destination as? ProductsListViewController {
            productsListViewController.title = destinationTitle
            productsListViewController.sortingValue = sortingValue
            destinationTitle = nil
        } else if let productDetailsViewController = segue.destination as? ProductDetailsViewController {
            productDetailsViewController.productId = selectedProduct!.id
        } else if let articleDetailsViewController = segue.destination as? ArticleDetailsViewController {
            articleDetailsViewController.articleId = selectedArticle!.id
        }
    }
    
    override func pullToRefreshHandler() {
        loadData()
    }
    
    private func updateNavigationBar() {
        navigationItem.title = "ControllerTitle.Home".localizable
        addCartBarButton()
    }
    
    private func setupTableView() {
        let lastArrivalsNib = UINib(nibName: String(describing: LastArrivalsTableViewCell.self), bundle: nil)
        tableView.register(lastArrivalsNib, forCellReuseIdentifier: String(describing: LastArrivalsTableViewCell.self))
        
        let popularNib = UINib(nibName: String(describing: PopularTableViewCell.self), bundle: nil)
        tableView.register(popularNib, forCellReuseIdentifier: String(describing: PopularTableViewCell.self))
        
        let newInBlogNib = UINib(nibName: String(describing: ArticleTableViewCell.self), bundle: nil)
        tableView.register(newInBlogNib, forCellReuseIdentifier: String(describing: ArticleTableViewCell.self))
                
        dataSource = HomeTableDataSource()
        dataSource.delegate = self
        tableView.dataSource = dataSource
        
        delegate = HomeTableDelegate()
        delegate.delegate = self
        tableView.delegate = delegate
        
        tableView.contentInset = TableView.defaultContentInsets
    }
    
    private func setupViewModel() {
        viewModel.data.asObservable()
            .subscribe(onNext: { [weak self] _ in
                self?.stopLoadAnimating()
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
    }
    
    private func loadData() {
        viewModel.loadData(with: disposeBag)
    }
    
    // MARK: - HomeTableDataSourceProtocol
    
    func lastArrivalsObjects() -> [Product] {
        return viewModel.data.value.latestProducts
    }
    
    func popularObjects() -> [Product] {
        return viewModel.data.value.popularProducts
    }
    
    func articlesCount() -> Int {
        return viewModel.data.value.articles.count
    }
    
    func article(at index: Int) -> Article? {
        if index < viewModel.data.value.articles.count {
            return viewModel.data.value.articles[index]
        }
        return nil
    }
    
    // MARK: - HomeTableDelegateProtocol
    
    func didSelectArticle(at index: Int) {
        if index < viewModel.data.value.articles.count {
            selectedArticle = viewModel.data.value.articles[index]
            performSegue(withIdentifier: SegueIdentifiers.toArticleDetails, sender: self)
        }
    }
    
    // MARK: - LastArrivalsCellDelegate
    
    func didSelectLastArrivalsProduct(at index: Int) {
        openProductDetails(with: viewModel.data.value.latestProducts, index: index)
    }
    
    // MARK: - PopularCellDelegate
    
    func didSelectPopularProduct(at index: Int) {
        openProductDetails(with: viewModel.data.value.popularProducts, index: index)
    }
    
    private func openProductDetails(with products: [Product], index: Int) {
        if index < products.count {
            selectedProduct = products[index]
            performSegue(withIdentifier: SegueIdentifiers.toProductDetails, sender: self)
        }
    }
    
    // MARK: - SeeAllHeaderViewProtocol
    
    func didTapSeeAll(type: SeeAllViewType) {
        switch type {
        case .latestArrivals:
            destinationTitle = "ControllerTitle.LatestArrivals".localizable
            sortingValue = .createdAt
            performSegue(withIdentifier: SegueIdentifiers.toProductsList, sender: self)
        case .blogPosts:
            performSegue(withIdentifier: SegueIdentifiers.toArticlesList, sender: self)
        default:
            return
        }
    }
    
    // MARK: - ErrorViewProtocol
    
    func didTapTryAgain() {
        viewModel.loadData(with: disposeBag)
    }
}
