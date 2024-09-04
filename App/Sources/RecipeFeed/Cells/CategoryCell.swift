// 
//  CategoryCellCell.swift
//  Recipes
//
//  Created by Peter Schuette on 9/3/24.
//

import AsyncState
import Foundation
import UIKit

final class CategoryCell: UICollectionViewCell, ConfigurableCell {
    static let reuseIdentifier = "\(Bundle.main.bundleIdentifier ?? "").CategoryCell"
    
    private lazy var imageView = UIImageView(frame: .zero)
    private lazy var titleLabel = UILabel(frame: .zero)
    private var imageTask: Task<Void, Never>?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }

    @available(*, unavailable, message: "Storyboards are not supported. Use ``init(frame:)``")    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        // reset the cell
        imageTask?.cancel()
        imageView.image = RecipesAsset.Assets.categoryPlaceholder.image
        titleLabel.text = nil
    }
}

// MARK: - Subview
extension CategoryCell {
    struct Configuration: ViewConfiguration {
        let url: URL
        let title: String
        let isSelected: Bool
    }

    func setupSubviews() {
        contentView.clipsToBounds = true

        contentView.addSubview(imageView)
        imageView.contentMode = .scaleAspectFill
        imageView.image = RecipesAsset.Assets.categoryPlaceholder.image

        contentView.addSubview(titleLabel)
        titleLabel.font = UIFont.preferredFont(forTextStyle: .title2)
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.textAlignment = .center
        // TODO: title label styling
        
        NSLayoutConstraint.activate([
            // Pin image to content
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            // Pin title to bottom
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
            titleLabel.rightAnchor.constraint(lessThanOrEqualTo: contentView.rightAnchor, constant: -16)
        ])
    }

    func apply(_ configuration: Configuration) {
        titleLabel.text = configuration.title
        imageTask = Task { [weak self] in
            let imageRequest = URLRequest(
                url: configuration.url,
                cachePolicy: .returnCacheDataElseLoad
            )

            guard 
                let imageData = try? await URLSession.shared.data(for: imageRequest).0,
                let image = UIImage(data: imageData)
            else { return }

            self?.setImage(image)
        }
    }
    

    @MainActor
    private func setImage(_ image: UIImage) {
        self.imageView.image = image
    }
}
