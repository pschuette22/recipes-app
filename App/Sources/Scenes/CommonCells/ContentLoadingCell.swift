//
//  ContentLoadingCell.swift
//  Recipes
//
//  Created by Peter Schuette on 9/4/24.
//

import AsyncState
import Foundation
import UIKit

final class ContentLoadingCell: UICollectionViewCell, ConfigurableCell {
    static let reuseIdentifier = "\(Bundle.main.bundleIdentifier ?? "").ContentLoadingCell"

    @ExplicitConstraints
    private var activityIndicator = UIActivityIndicatorView(style: .large)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }

    @available(*, unavailable, message: "Storyboards are not supported. Use ``init(frame:)``")
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        // reset the cell
        activityIndicator.stopAnimating()
    }
}

// MARK: - Subview

extension ContentLoadingCell {
    struct Configuration: ViewConfiguration {
        var isAnimating: Bool
    }

    func setupSubviews() {
        contentView.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    func apply(_ configuration: Configuration) {
        if configuration.isAnimating {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
}
