// 
//  MealCell.swift
//  Recipes
//
//  Created by Peter Schuette on 9/7/24.
//

import AsyncState
import Foundation
import UIKit

final class MealCell: UICollectionViewCell, ConfigurableCell {
    static let reuseIdentifier = "\(Bundle.main.bundleIdentifier ?? "").MealCell"
    
    private lazy var imageView = UIImageView(frame: .zero)
    private lazy var titleLabel = UILabel(frame: .zero)
    private var imageTask: Task<Void, Error>?
    
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
        imageView.image = nil
        titleLabel.text = nil
    }
    
    @MainActor
    func setImage(_ image: UIImage) {
        imageView.image = image
    }
}

// MARK: - Subview
extension MealCell {
    struct Configuration: ViewConfiguration {
        var image: URL
        var title: String
    }

    func setupSubviews() {
        contentView.addSubview(imageView)
        imageView.contentMode = .scaleAspectFill

        contentView.addSubview(titleLabel)
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.preferredFont(forTextStyle: .title3)
        titleLabel.textColor = UIColor.label
        
        NSLayoutConstraint.activate([
            // Image constraints
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 8),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            imageView.heightAnchor.constraint(equalToConstant: 150),
            imageView.widthAnchor.constraint(equalToConstant: 150),
            // Title Constraints
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: 16),
            titleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16)
        ])
    }

    func apply(_ configuration: Configuration) {
        titleLabel.text = configuration.title
        imageTask = Task { [weak self] in
            let imageRequest = URLRequest(
                url: configuration.image,
                cachePolicy: .returnCacheDataElseLoad
            )

            let imageData = try await URLSession.shared.data(for: imageRequest).0

            guard
                let image = UIImage(data: imageData)
            else { return }

            self?.setImage(image)
        }        
    }
}
