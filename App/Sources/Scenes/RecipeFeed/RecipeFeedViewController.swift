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
        navigationItem.backButtonTitle = ""
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(ContentLoadingCell.self)
        collectionView.register(CategoryCell.self)
        collectionView.register(MealCell.self)

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
                guard 
                    let state = self?.viewModel.state
                else {
                    return .empty
                }
                
                switch state.section(at: sectionIndex) {
                case .categories:
                    let itemSize: NSCollectionLayoutSize = state.isLoadingCategories
                        ? NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(200))
                        : NSCollectionLayoutSize(widthDimension: .absolute(180), heightDimension: .absolute(180))
                    let group = NSCollectionLayoutGroup.horizontal(
                        layoutSize: itemSize,
                        subitems: [NSCollectionLayoutItem(
                            layoutSize: itemSize
                        )]
                    )
                    let section = NSCollectionLayoutSection(
                        group: group
                    )
                    section.contentInsets = .init(top: 16, leading: 16, bottom: 16, trailing: 16)
                    section.interGroupSpacing = 16.0
                    section.orthogonalScrollingBehavior = .continuous
                    return section
                case .meals:
                    let itemSize: NSCollectionLayoutSize = state.isLoadingMeals
                        ? NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(environment.container.contentSize.height - 200))
                        : NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(132)) // 150 + 16 * 2
                    let group = NSCollectionLayoutGroup.vertical(
                        layoutSize: itemSize,
                        subitems: [NSCollectionLayoutItem(
                            layoutSize: itemSize
                        )]
                    )
                    let section = NSCollectionLayoutSection(group: group)
                    return section
                }
            },
            configuration: configuration
        )
    }
    
    private func makeDataSource(for collectionView: UICollectionView) -> DataSource<Sections, Items> {
        DataSource(
            collectionView: collectionView
        ) { [weak self] collectionView, indexPath, itemIdentifier in
            guard let item = self?.viewModel.state.item(at: indexPath) else { return nil }
            
            switch item {
            case .contentLoading(let configuration):
                return collectionView.dequeueCell(ContentLoadingCell.self, withConfiguration: configuration, for: indexPath)
            case .category(let configuration):
                return collectionView.dequeueCell(CategoryCell.self, withConfiguration: configuration, for: indexPath)
            case .meal(let configuration):
                return collectionView.dequeueCell(MealCell.self, withConfiguration: configuration, for: indexPath)
            }
        }
    }
}

// MARK: - UICollectionViewDelegate

extension RecipeFeedViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = viewModel.state.sections[safe: indexPath.section] else { return }
        
        switch section {
        case .categories:
            viewModel.didSelectCategory(at: indexPath.row)
        case .meals:
            guard let mealViewModel = viewModel.viewModel(forMealAt: indexPath.row) else { return }
            let controller = MealDetailsViewController(viewModel: mealViewModel)
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}
