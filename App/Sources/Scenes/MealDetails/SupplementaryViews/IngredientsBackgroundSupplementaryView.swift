// 
//  IngredientsBackgroundSupplementaryView.swift
//  Recipes
//
//  Created by Peter Schuette on 9/9/24.
//

import AsyncState
import Foundation
import UIKit

final class IngredientsBackgroundSupplementaryView: UICollectionReusableView, ConfigurableSupplementaryView {
    static let reuseIdentifier = "\(Bundle.main.bundleIdentifier ?? "").IngredientsBackgroundSupplementaryView"

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
       // initialize what is needed
    }

    @available(*, unavailable, message: "Storyboards are not supported. Use ``init(frame:)``")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Subview
extension IngredientsBackgroundSupplementaryView {
    struct Configuration: ViewConfiguration { }

    func setupSubviews() {
        backgroundColor = UIColor.systemGroupedBackground
        layer.cornerRadius = 16.0
        layer.shadowColor = traitCollection.preferredShadowColor.cgColor
        layer.shadowRadius = 3
        layer.masksToBounds = false
        layer.shadowOffset = .zero
        layer.shadowOpacity = 0.3
    }

    func apply(_ configuration: Configuration) {
        // Apply the layout configuration
    }
}
