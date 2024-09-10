// 
//  IngredientsHeaderSupplementaryView.swift
//  Recipes
//
//  Created by Peter Schuette on 9/9/24.
//

import AsyncState
import Foundation
import UIKit

final class IngredientsHeaderSupplementaryView: UICollectionReusableView, ConfigurableSupplementaryView {
    static let reuseIdentifier = "\(Bundle.main.bundleIdentifier ?? "").IngredientsHeaderSupplementaryView"
    
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
extension IngredientsHeaderSupplementaryView {
    struct Configuration: ViewConfiguration {}

    func setupSubviews() {
        addSubview(ingredientLabel)
        ingredientLabel.numberOfLines = 0
        ingredientLabel.lineBreakMode = .byWordWrapping
        ingredientLabel.font = UIFont.preferredFont(forTextStyle: .title2)
        ingredientLabel.textColor = UIColor.label
        ingredientLabel.textAlignment = .center
        ingredientLabel.text = "Ingredient"

        addSubview(measurementLabel)
        measurementLabel.numberOfLines = 0
        measurementLabel.lineBreakMode = .byWordWrapping
        measurementLabel.font = UIFont.preferredFont(forTextStyle: .title2)
        measurementLabel.textColor = UIColor.label
        measurementLabel.textAlignment = .center
        measurementLabel.text = "Amount"

        NSLayoutConstraint.activate([
            // Measurement Label
            measurementLabel.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 11),
            measurementLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -8),
            measurementLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            measurementLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.35),
            measurementLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -8),

            // Ingredient Label
            ingredientLabel.topAnchor.constraint(equalTo: topAnchor, constant: 11),
            ingredientLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 8),
            ingredientLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            ingredientLabel.rightAnchor.constraint(equalTo: measurementLabel.leftAnchor, constant: -16),
        ])
    }

    func apply(_ configuration: Configuration) { }
}
