//
//  CharacterDetailsViewController.swift
//  MarvelHeroes
//
//  Created by Tarkhan Tahirov on 07.06.22.
//

import UIKit
import SnapKit

class CharacterDetailsViewController: UIViewController {
    
    let cellId = "DetailsTableCellId"
    
    var characterImageView = UIImageView()
    var descriptionLabel = UILabel()
    var detailsTableView = UITableView()
    
    var viewModel: CharacterDetailsViewModelType
    var imageService: ImageService
    
    init(with viewModel: CharacterDetailsViewModelType, imageService: ImageService = MarvelImageClient.shared) {
        self.viewModel = viewModel
        self.imageService = imageService
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        bindViewModel()
    }
    
    func setupViews() {
        view.backgroundColor = .secondarySystemBackground
        
        characterImageView.translatesAutoresizingMaskIntoConstraints = false
        characterImageView.backgroundColor = .lightGray
        
        view.addSubview(characterImageView)
        
        let safeArea = view.safeAreaLayoutGuide
        characterImageView.snp.makeConstraints {
            $0.leading.equalTo(safeArea)
            $0.top.equalTo(safeArea)
            $0.trailing.equalTo(safeArea)
            $0.height.equalTo(350)
        }
        
        descriptionLabel.font = .systemFont(ofSize: 13)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.numberOfLines = 0
        
        view.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints {
            $0.leading.equalTo(safeArea).inset(16)
            $0.trailing.equalTo(safeArea).inset(16)
            $0.top.equalTo(characterImageView.snp.bottom).offset(20)
        }
        
        detailsTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        detailsTableView.delegate = self
        detailsTableView.dataSource = self
        detailsTableView.backgroundColor = .clear
        detailsTableView.showsVerticalScrollIndicator = false
        detailsTableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(detailsTableView)
        detailsTableView.snp.makeConstraints {
            $0.leading.equalTo(safeArea)
            $0.trailing.equalTo(safeArea)
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(10)
            $0.bottom.equalTo(safeArea)
        }
    }
    
    func bindViewModel() {
        title = viewModel.characterName
        descriptionLabel.text = viewModel.characterDescription
        imageService.setImage(
            fromURL: viewModel.characterImageURL,
            imageView: characterImageView
        )
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
}

extension CharacterDetailsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.tableDataSource[section].0
    }
    
}

extension CharacterDetailsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.tableDataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tableDataSource[section].1.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId)!
        let items = viewModel.tableDataSource[indexPath.section].1
        cell.backgroundColor = .clear
        cell.textLabel?.text = items[indexPath.row].name
        return cell
    }
    
}
