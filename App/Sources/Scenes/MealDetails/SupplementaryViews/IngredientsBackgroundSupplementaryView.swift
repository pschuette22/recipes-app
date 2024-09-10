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

    override func prepareForReuse() {
        super.prepareForReuse()
        // reset the cell
    }
}

// MARK: - Subview
extension IngredientsBackgroundSupplementaryView {
    struct Configuration: ViewConfiguration { }

    func setupSubviews() {
        backgroundColor = UIColor.systemGroupedBackground
        layer.cornerRadius = 16.0
    }

    func apply(_ configuration: Configuration) {
        // Apply the layout configuration
    }
}
