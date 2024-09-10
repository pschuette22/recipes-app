// 
//  RecipeHeaderSupplementaryView.swift
//  Recipes
//
//  Created by Peter Schuette on 9/9/24.
//

import AsyncState
import Foundation
import UIKit

final class RecipeHeaderView: UIView {
    @ExplicitConstraints
    private var imageView = UIImageView(frame: .zero)
    
    @ExplicitConstraints
    private var titleLabel = UILabel(frame: .zero)

    var titleFrame: CGRect {
        return titleLabel.frame
    }
    
    private var titleTransitionAnimator: UIViewPropertyAnimator?
    private var isAnimatingHide: Bool?
    
    private var imageTask: Task<Void, Never>?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    @available(*, unavailable, message: "Storyboards are not supported. Use ``init(frame:)``")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        nil
    }
}

// MARK: - Subview
extension RecipeHeaderView {
    struct Configuration: ViewConfiguration {
        var imageURL: URL
        var title: String
    }

    func setupSubviews() {
        backgroundColor = .systemBackground
        clipsToBounds = true
        addSubview(imageView)
        imageView.clipsToBounds = true
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
        titleLabel.text = configuration.title
        set(titleTransitionPercentage: 1)
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
    
    @MainActor
    func set(titleTransitionPercentage: CGFloat) {
        let alphaPercentage = min(max(0, titleTransitionPercentage), 1)
        imageView.alpha = 0.4 + (alphaPercentage * 0.3)
    }
    
    @MainActor
    func set(titleIsHidden: Bool) {
        guard
            titleIsHidden != titleLabel.isHidden,
            titleIsHidden != isAnimatingHide
        else { return }
        
        isAnimatingHide = titleIsHidden
        titleTransitionAnimator?.stopAnimation(true)
        titleTransitionAnimator = UIViewPropertyAnimator(duration: 0.0001, curve: .easeInOut)
        titleTransitionAnimator?.addAnimations { [titleLabel] in
            titleLabel.alpha = titleIsHidden ? 0 : 1
            titleLabel.isHidden = false
        }
        titleTransitionAnimator?.addCompletion { [weak self] position in
            guard position == .end else { return /* ignore cancelation */ }
            self?.titleLabel.isHidden = titleIsHidden
            self?.isAnimatingHide = nil
        }
        titleTransitionAnimator?.startAnimation()
    }
}
