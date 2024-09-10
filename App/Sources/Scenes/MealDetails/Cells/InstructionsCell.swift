// 
//  InstructionsCell.swift
//  Recipes
//
//  Created by Peter Schuette on 9/9/24.
//

import AsyncState
import Foundation
import UIKit

final class InstructionsCell: UICollectionViewCell, ConfigurableCell {
    static let reuseIdentifier = "\(Bundle.main.bundleIdentifier ?? "").InstructionsCell"

    @ExplicitConstraints
    private var textView = UITextView(frame: .zero)

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
extension InstructionsCell {
    struct Configuration: ViewConfiguration {
        var instructions: String
    }

    func setupSubviews() {
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.textContainerInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.textColor = UIColor.label
        contentView.addSubview(textView)
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: contentView.topAnchor),
            textView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            textView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    func apply(_ configuration: Configuration) {
        textView.text = configuration.instructions
    }
}
