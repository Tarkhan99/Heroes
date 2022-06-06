//
//  CharacterCell.swift
//  MarvelHeroes
//
//  Created by Tarkhan Tahirov on 05.06.22.
//

import UIKit
import SnapKit

class CharacterCell: UICollectionViewCell {
    
    static let id = "CharacterCell"
    
    var imageView: UIImageView!
    var nameLabel: UILabel!
    var descriptionLabel: UILabel!
    
    var imageService: ImageService = MarvelImageClient.shared
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = true
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 10
        
        nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.textColor = .white
        nameLabel.font = .systemFont(ofSize: 16, weight: .bold)
        
        descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.textColor = .white
        descriptionLabel.numberOfLines = 3
        descriptionLabel.font = .systemFont(ofSize: 13)
        
        contentView.addSubview(imageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(descriptionLabel)
        
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(self.contentView).inset(8)
            $0.trailing.equalTo(self.contentView).inset(8)
            $0.top.equalTo(self.contentView).inset(8)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.leading.equalTo(self.contentView).inset(8)
            $0.trailing.equalTo(self.contentView).inset(8)
            $0.bottom.equalTo(self.contentView).inset(8)
        }
        
    }
    
    func configure(with viewModel: CharacterCellViewModelType) {
        nameLabel.text = viewModel.name
        descriptionLabel.text = viewModel.description
        imageService.setImage(fromURL: viewModel.imageURL, imageView: imageView)
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
}
