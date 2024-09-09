// 
//  MealDetailsViewController.swift
//  Recipes
//
//  Created by Peter Schuette on 9/9/24.
//

import AsyncState
import Foundation
import UIKit

@Modeled(MealDetailsState.self, MealDetailsViewModel.self)
final class MealDetailsViewController: UIViewController {
    private static let pageHeaderKind = "page-header"

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

extension MealDetailsViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        setupSubviews()
        startObservingState(renderImmediately: true)
    }
}

// MARK: - Subviews

extension MealDetailsViewController {
    ///  Prepare subviews for state rendering
    private func setupSubviews() {
        let titleView = UIView(frame: .zero)
        titleView.backgroundColor = .clear
        let navigationAppearance = UINavigationBarAppearance()
        navigationAppearance.configureWithTransparentBackground()

        navigationItem.standardAppearance = navigationAppearance
        navigationItem.scrollEdgeAppearance = navigationAppearance

        collectionView.register(RecipeHeaderSupplementaryView.self, ofKind: Self.pageHeaderKind)

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
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

extension MealDetailsViewController {
    private typealias DataSource = UICollectionViewDiffableDataSource
    typealias Sections = State.Sections
    typealias Items = State.Items
    
    
    @MainActor
    private func makeLayout() -> UICollectionViewLayout {
        // https://developer.apple.com/documentation/uikit/uicollectionviewcompositionallayout
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        
        let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(250)),
            elementKind: Self.pageHeaderKind,
            alignment: .top
        )

        configuration.boundarySupplementaryItems = [
            headerItem
        ]
        
        let layout = UICollectionViewCompositionalLayout(
            sectionProvider: { [weak self] sectionIndex, environment in
                // TODO: return section configuration
                return nil
            }, 
            configuration: configuration
        )

        return layout
    }
    
    private func makeDataSource(for collectionView: UICollectionView) -> DataSource<Sections, Items> {
        let dataSource = DataSource<Sections, Items>(
            collectionView: collectionView
        ) { collectionView, indexPath, itemIdentifier in
            // TODO: turn into configured cells
            nil
        }
        
        dataSource.supplementaryViewProvider = { [weak self] collection, element, indexPath in
            guard let state = self?.viewModel.state else { return nil }

            switch element {
            case Self.pageHeaderKind:
                let header = collection.dequeueSupplementaryView(
                    RecipeHeaderSupplementaryView.self,
                    withConfiguration: .init(imageURL: state.photoURL, title: state.title),
                    ofKind: Self.pageHeaderKind,
                    for: indexPath
                )
                return header
            default:
                return nil
            }
        }
        
        return dataSource
    }
}

// MARK: - UICollectionViewDelegate

extension MealDetailsViewController: UICollectionViewDelegate {
    // TODO: handle delegate functions
}
