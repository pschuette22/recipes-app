// 
//  InstructionsHeaderSupplementaryView.swift
//  Recipes
//
//  Created by Peter Schuette on 9/10/24.
//

import AsyncState
import Foundation
import UIKit

final class InstructionsHeaderSupplementaryView: UICollectionReusableView, ConfigurableSupplementaryView {
    static let reuseIdentifier = "\(Bundle.main.bundleIdentifier ?? "").InstructionsHeaderSupplementaryView"

    @ExplicitConstraints
    private var headerLabel = UILabel(frame: .zero)

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
extension InstructionsHeaderSupplementaryView {
    struct Configuration: ViewConfiguration { }

    func setupSubviews() {
        addSubview(headerLabel)
        headerLabel.text = "Instructions"
        headerLabel.font = UIFont.preferredFont(forTextStyle: .title2)
        headerLabel.textColor = UIColor.label
        headerLabel.numberOfLines = 1
        headerLabel.lineBreakMode = .byTruncatingTail
        headerLabel.textAlignment = .center

        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            headerLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 8),
            headerLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -8),
            headerLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }

    func apply(_ configuration: Configuration) {
        // Apply the layout configuration
    }
}
