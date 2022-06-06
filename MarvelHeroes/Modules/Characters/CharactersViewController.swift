//
//  HeroesListViewController.swift
//  MarvelHeroes
//
//  Created by Tarkhan Tahirov on 04.06.22.
//

import UIKit
import SnapKit

class CharactersViewController: UIViewController {
    
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: getCompositionalLayout())
    lazy var searchController = UISearchController()
    lazy var activityIndicator = UIActivityIndicatorView(style: .large)
    
    var viewModel: CharactersListViewModelType
    
    init(with viewModel: CharactersListViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchController()
        setupCollectionView()
        setupViewModel()
    }
    
    func setupCollectionView() {
        collectionView.showsVerticalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(CharacterCell.self, forCellWithReuseIdentifier: CharacterCell.id)
        collectionView.dataSource = self
        collectionView.delegate = self
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
    }
    
    func setupSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search..."
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    func setupViewModel() {
        viewModel.reloadCollectionView = { [weak self] in
            self?.collectionView.reloadData()
        }
        
        viewModel.updateLoadingStatus = { [unowned self] in
            if self.viewModel.isLoading {
                self.activityIndicator.startAnimating()
            } else {
                self.activityIndicator.stopAnimating()
            }
        }
        
        viewModel.fetchCharacters()
    }
    
}


extension CharactersViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.cellViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CharacterCell.id, for: indexPath) as! CharacterCell
        cell.configure(with: viewModel.cellViewModels[indexPath.row])
        return cell
    }
    
    
}

extension CharactersViewController: UICollectionViewDelegateFlowLayout {
    
    func getCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let fraction: CGFloat = 1 / 2
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(fraction), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.3))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (indexPath.row == viewModel.cellViewModels.count - 1) {
            viewModel.loadMoreCharacters()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let character = viewModel.charactersResponse?.data?.results?[indexPath.row]
        let detailsViewModel = CharacterDetailsViewModel(character: character)
        let detailsController = CharacterDetailsViewController(with: detailsViewModel)
        navigationController?.pushViewController(detailsController, animated: true)
    }
    
}

extension CharactersViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        viewModel.searchQuery = searchBar.text
        viewModel.fetchCharacters()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.searchQuery = nil
        viewModel.fetchCharacters()
    }
    
}
