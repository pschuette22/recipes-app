// 
//  RecipeHeaderSupplementaryView.swift
//  Recipes
//
//  Created by Peter Schuette on 9/9/24.
//

import AsyncState
import Foundation
import UIKit

final class RecipeHeaderSupplementaryView: UICollectionReusableView, ConfigurableSupplementaryView {
    static let reuseIdentifier = "\(Bundle.main.bundleIdentifier ?? "").RecipeHeaderSupplementaryView"
    
    @ExplicitConstraints
    private var imageView = UIImageView(frame: .zero)
    
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
    }
}

// MARK: - Subview
extension RecipeHeaderSupplementaryView {
    struct Configuration: ViewConfiguration {
        var imageURL: URL
        var title: String
    }

    func setupSubviews() {
        addSubview(imageView)
        imageView.contentMode = .scaleAspectFill
        addSubview(titleLabel)
        titleLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        NSLayoutConstraint.activate([
            // Image makes up the entire background
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leftAnchor.constraint(equalTo: leftAnchor),
            imageView.rightAnchor.constraint(equalTo: rightAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            // Title is centered
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor, constant: 24),
            titleLabel.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -24),
        ])
    }

    func apply(_ configuration: Configuration) {
        // Apply the layout configuration
        titleLabel.text = configuration.title
        
        imageTask = Task { [weak self] in
            let request = URLRequest(url: configuration.imageURL, cachePolicy: .returnCacheDataElseLoad)
            guard 
                let (data, _) = try? await URLSession.shared.data(for: request),
                let image = UIImage(data: data)
            else { return }
            
            self?.set(image: image)
        }
    }
    
    @MainActor
    func set(image: UIImage) {
        self.imageView.image = image
    }
}
