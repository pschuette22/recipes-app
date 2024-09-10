// 
//  HeaderAnchorSupplementaryView.swift
//  Recipes
//
//  Created by Peter Schuette on 9/9/24.
//

import AsyncState
import Foundation
import UIKit

final class HeaderAnchorSupplementaryView: UICollectionReusableView, ConfigurableSupplementaryView {
    static let reuseIdentifier = "\(Bundle.main.bundleIdentifier ?? "").HeaderAnchorSupplementaryView"
    
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
extension HeaderAnchorSupplementaryView {
    // TODO: Define transactions
    struct Configuration: ViewConfiguration {
        
    }

    func setupSubviews() {
        backgroundColor = .systemBackground
    }

    func apply(_ configuration: Configuration) { }
}
