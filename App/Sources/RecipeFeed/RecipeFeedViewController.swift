// 
//  RecipeFeedViewController.swift
//  Recipes
//
//  Created by Peter Schuette on 9/3/24.
//

import AsyncState
import Foundation
import UIKit

@Modeled(RecipeFeedState.self, RecipeFeedViewModel.self)
final class RecipeFeedViewController: UIViewController {
    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: collectionViewLayout
    )
    
    private lazy var collectionViewLayout: UICollectionViewLayout = makeLayout()
    private lazy var dataSource: DataSource = makeDataSource(for: collectionView)
    
    required init(viewModel: ViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable, message: "Storyboards are not supported. Use init(viewModel:)")
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Lifecycle

extension RecipeFeedViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        setupSubviews()
        startObservingState(renderImmediately: true)
        
        viewModel.viewDidLoad()
    }
}

// MARK: - Subviews

extension RecipeFeedViewController {
    ///  Prepare subviews for state rendering
    private func setupSubviews() {
        // TODO: Setup additional subviews
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        collectionView.dataSource = dataSource
        collectionView.delegate = self
    }

    @MainActor
    func render(_ state: State) {
        // TODO: Apply any new state changes
        dataSource.apply(state.snapshot, animatingDifferences: true)
    }
}

// MARK: - CollectionView

extension RecipeFeedViewController {
    private typealias DataSource = UICollectionViewDiffableDataSource
    typealias Sections = State.Sections
    typealias Items = State.Items
    
    
    @MainActor
    private func makeLayout() -> UICollectionViewLayout {
        // https://developer.apple.com/documentation/uikit/uicollectionviewcompositionallayout
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        
        return UICollectionViewCompositionalLayout(
            sectionProvider: { [weak self] sectionIndex, environment in
                // TODO: return section configuration
                return nil
            }, 
            configuration: configuration
        )
    }
    
    private func makeDataSource(for collectionView: UICollectionView) -> DataSource<Sections, Items> {
        DataSource(
            collectionView: collectionView
        ) { collectionView, indexPath, itemIdentifier in
            // TODO: turn into configured cells
            nil
        }
    }
}

// MARK: - UICollectionViewDelegate

extension RecipeFeedViewController: UICollectionViewDelegate {
    // TODO: handle delegate functions
}
