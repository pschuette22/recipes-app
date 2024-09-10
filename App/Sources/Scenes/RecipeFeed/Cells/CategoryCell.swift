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

    @ExplicitConstraints
    private var imageView = UIImageView(frame: .zero)

    @ExplicitConstraints
    private var titleContainer = UIView(frame: .zero)

    @ExplicitConstraints
    private var titleLabel = UILabel(frame: .zero)

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
        set(isSelected: false)
    }

    @MainActor
    private func setImage(_ image: UIImage) {
        self.imageView.image = image
    }
}

// MARK: - Subviews

extension CategoryCell {
    struct Configuration: ViewConfiguration {
        let image: URL
        let title: String
        let isSelected: Bool
    }

    func setupSubviews() {
        clipsToBounds = true
        contentView.layer.borderColor = UIColor.systemGroupedBackground.cgColor
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.image = RecipesAsset.Assets.categoryPlaceholder.image

        contentView.addSubview(titleContainer)
        titleContainer.translatesAutoresizingMaskIntoConstraints = false
        titleContainer.backgroundColor = UIColor.tertiarySystemBackground.withAlphaComponent(0.8)

        titleContainer.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.preferredFont(forTextStyle: .title2)
        titleLabel.textColor = UIColor.label
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.textAlignment = .center

        NSLayoutConstraint.activate([
            // Pin image to content
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            // Pin title container to bottom of image
            titleContainer.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            titleContainer.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            titleContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            // Pin title to bottom
            titleLabel.topAnchor.constraint(equalTo: titleContainer.topAnchor, constant: 8),
            titleLabel.bottomAnchor.constraint(equalTo: titleContainer.bottomAnchor, constant: -8),
            titleLabel.leftAnchor.constraint(equalTo: titleContainer.leftAnchor, constant: 8),
            titleLabel.rightAnchor.constraint(lessThanOrEqualTo: titleContainer.rightAnchor, constant: -8)
        ])
    }

    func apply(_ configuration: Configuration) {
        titleLabel.text = configuration.title
        imageTask = Task { [weak self] in
            let imageRequest = URLRequest(
                url: configuration.image,
                cachePolicy: .returnCacheDataElseLoad
            )

            guard
                let imageData = try? await URLSession.shared.data(for: imageRequest).0,
                let image = UIImage(data: imageData)
            else { return }

            self?.setImage(image)
        }

        set(isSelected: configuration.isSelected)
    }

    private func set(isSelected: Bool) {
        contentView.layer.borderWidth = isSelected ? 8 : 0
    }
}
