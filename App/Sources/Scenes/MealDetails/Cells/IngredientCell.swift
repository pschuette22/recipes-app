// 
//  IngredientCell.swift
//  Recipes
//
//  Created by Peter Schuette on 9/9/24.
//

import AsyncState
import Foundation
import UIKit

final class IngredientCell: UICollectionViewCell, ConfigurableCell {
    static let reuseIdentifier = "\(Bundle.main.bundleIdentifier ?? "").IngredientCell"

    @ExplicitConstraints
    private var ingredientLabel = UILabel(frame: .zero)
    @ExplicitConstraints
    private var measurementLabel = UILabel(frame: .zero)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }

    @available(*, unavailable, message: "Storyboards are not supported. Use ``init(frame:)``")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Subview
extension IngredientCell {
    struct Configuration: ViewConfiguration {
        let ingredient: String
        let measurement: String
    }

    func setupSubviews() {
        contentView.addSubview(ingredientLabel)
        ingredientLabel.numberOfLines = 0
        ingredientLabel.lineBreakMode = .byWordWrapping
        ingredientLabel.font = UIFont.preferredFont(forTextStyle: .body)
        ingredientLabel.textColor = UIColor.label
        ingredientLabel.textAlignment = .natural

        contentView.addSubview(measurementLabel)
        measurementLabel.numberOfLines = 0
        measurementLabel.lineBreakMode = .byWordWrapping
        measurementLabel.font = UIFont.preferredFont(forTextStyle: .body)
        measurementLabel.textColor = UIColor.secondaryLabel
        measurementLabel.textAlignment = .center

        NSLayoutConstraint.activate([
            // Measurement Label
            measurementLabel.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 8),
            measurementLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8),
            measurementLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            measurementLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.35),
            measurementLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8),
            // Ingredient Label
            ingredientLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            ingredientLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 8),
            ingredientLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            ingredientLabel.rightAnchor.constraint(equalTo: measurementLabel.leftAnchor, constant: -16)
        ])
    }

    func apply(_ configuration: Configuration) {
        ingredientLabel.text = configuration.ingredient
        measurementLabel.text = configuration.measurement
    }
}
