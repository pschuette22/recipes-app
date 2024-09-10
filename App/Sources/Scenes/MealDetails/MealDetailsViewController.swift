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
    private static let ingredientsHeaderKind = "ingredients-header"
    private static let ingredientBackgroundKind = "ingredients-background"
    private static let instructionsHeaderKind = "instructions-header"

    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: collectionViewLayout
    )
    
    @ExplicitConstraints
    private var headerView = RecipeHeaderView(frame: .zero)
    private lazy var headerHeightConstraint = headerView.heightAnchor.constraint(
        equalToConstant: (navigationController?.navigationBar.frame.maxY ?? 0) + 150 - 16
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
        
        viewModel.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reframeHeader()
        navigationItem.leftBarButtonItem?.tintColor = UIColor.darkText
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
        let barButtonAppearance = UIBarButtonItemAppearance(style: .plain)
        barButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.darkText]
        let image = UIImage(systemName: "chevron.backward")?.withTintColor(.darkText, renderingMode: .alwaysOriginal)
        navigationAppearance.setBackIndicatorImage(image, transitionMaskImage: image)
        navigationAppearance.backButtonAppearance = barButtonAppearance
        navigationItem.standardAppearance = navigationAppearance
        navigationItem.scrollEdgeAppearance = navigationAppearance
        

        collectionView.register(HeaderAnchorSupplementaryView.self, ofKind: Self.pageHeaderKind)
        collectionView.register(IngredientsHeaderSupplementaryView.self, ofKind: Self.ingredientsHeaderKind)
        collectionView.register(InstructionsHeaderSupplementaryView.self, ofKind: Self.instructionsHeaderKind)
        collectionView.register(IngredientCell.self)
        collectionView.register(InstructionsCell.self)

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = UIColor.systemBackground
        collectionView.showsVerticalScrollIndicator = false

        view.addSubview(collectionView)
        view.addSubview(headerView)

        NSLayoutConstraint.activate([
            // Collection view
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            // HeaderView
            headerView.topAnchor.constraint(equalTo: collectionView.topAnchor),
            headerView.leftAnchor.constraint(equalTo: collectionView.leftAnchor),
            headerView.widthAnchor.constraint(equalTo: collectionView.widthAnchor),
            headerHeightConstraint,
        ])
        
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        
        headerView.apply(.init(imageURL: viewModel.state.photoURL, title: viewModel.state.title))
    }

    @MainActor
    func render(_ state: State) {
        dataSource.apply(state.snapshot, animatingDifferences: true)
    }
    
    private func reframeHeader() {
        guard let anchorY = collectionView.supplementaryView(forElementKind: Self.pageHeaderKind, at: IndexPath(index: 0))?.frame.maxY else { return }

        let maxY = navigationController?.navigationBar.frame.maxY ?? 20 // Shouldn't ever fallback
        let height = max(anchorY - collectionView.contentOffset.y - 16, maxY)

        UIView.animate(withDuration: .zero) { [weak self] in
            self?.headerHeightConstraint.constant = height
        }

        headerView.set(titleTransitionPercentage: min(((height - maxY) / maxY), 1))
    }
    
    private func updateTitleDisplay() {
        guard let navbarMidY = navigationController?.navigationBar.frame.midY else { return }
        let isHeaderTitleHidden = navbarMidY > headerView.titleFrame.midY
        headerView.set(titleIsHidden: isHeaderTitleHidden)
        navigationItem.title = isHeaderTitleHidden ? viewModel.state.title : nil
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
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(150)),
            elementKind: Self.pageHeaderKind,
            alignment: .top
        )
        
        configuration.boundarySupplementaryItems = [
            headerItem
        ]

        configuration.interSectionSpacing = 16
        
        let layout = UICollectionViewCompositionalLayout(
            sectionProvider: { [weak self] sectionIndex, environment in
                guard
                    let state = self?.viewModel.state
                else {
                    return .empty
                }
                
                switch state.section(at: sectionIndex) {
                case .ingredients:
                    let ingredientCount = state.sectionItems[.ingredients]?.count ?? 0
                    let estimatedItemHeight = UIFont.preferredFont(forTextStyle: .body).lineHeight + 16
                    let itemSize = NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .estimated(estimatedItemHeight)
                    )
                    
                    let ingredientsGroup = NSCollectionLayoutGroup.vertical(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .estimated(estimatedItemHeight * CGFloat(ingredientCount))
                        ),
                        subitems: Array(repeating: NSCollectionLayoutItem(layoutSize: itemSize), count: ingredientCount)
                    )
        
                    let estimatedHeaderHeight = UIFont.preferredFont(forTextStyle: .title2).lineHeight + 16
                    let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                        layoutSize: .init(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .estimated(estimatedHeaderHeight)
                        ),
                        elementKind: Self.ingredientsHeaderKind,
                        alignment: .top
                    )
                    sectionHeader.extendsBoundary = true
                    
                    let section = NSCollectionLayoutSection(group: ingredientsGroup)
                    section.contentInsets = .init(top: 3, leading: 24, bottom: 24, trailing: 24)

                    let backgroundItem = NSCollectionLayoutDecorationItem.background(elementKind: Self.ingredientBackgroundKind)
                    backgroundItem.contentInsets = .init(top: 3, leading: 16, bottom: 16, trailing: 16)
                    section.boundarySupplementaryItems = [
                        sectionHeader
                    ]
                    section.decorationItems = [
                        backgroundItem
                    ]

                    return section
                    
                case .instructions:
                    let estimatedHeight = UIFont.preferredFont(forTextStyle: .body).lineHeight
                    let itemSize = NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .estimated(estimatedHeight)
                    )
                    let instructionGroup = NSCollectionLayoutGroup.vertical(
                        layoutSize: itemSize,
                        subitems: [.init(layoutSize: itemSize)]
                    )
                    let section = NSCollectionLayoutSection(group: instructionGroup)
                    
                    let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                        layoutSize: .init(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .estimated(UIFont.preferredFont(forTextStyle: .title2).lineHeight + 24)
                        ),
                        elementKind: Self.instructionsHeaderKind,
                        alignment: .top
                    )
                    
                    section.boundarySupplementaryItems = [
                        sectionHeader
                    ]
                    
                    section.contentInsets = .init(top: 0, leading: 24, bottom: 24, trailing: 24)
                    return section
                }
            },
            configuration: configuration
        )
        
        layout.register(IngredientsBackgroundSupplementaryView.self, forDecorationViewOfKind: Self.ingredientBackgroundKind)

        return layout
    }
    
    private func makeDataSource(for collectionView: UICollectionView) -> DataSource<Sections, Items> {
        let dataSource = DataSource<Sections, Items>(
            collectionView: collectionView
        ) { [weak self] collectionView, indexPath, itemIdentifier in
            guard let item = self?.viewModel.state.item(at: indexPath) else { return nil }
            
            switch item {
            case .ingredient(let configuration):
                return collectionView.dequeueCell(IngredientCell.self, withConfiguration: configuration, for: indexPath)
            case .instructions(let configuration):
                return collectionView.dequeueCell(InstructionsCell.self, withConfiguration: configuration, for: indexPath)
            }
        }
        
        dataSource.supplementaryViewProvider = { collection, element, indexPath in
            switch element {
            case Self.pageHeaderKind:
                return collection.dequeueSupplementaryView(
                    HeaderAnchorSupplementaryView.self,
                    withConfiguration: .init(),
                    ofKind: Self.pageHeaderKind,
                    for: indexPath
                )
            case Self.ingredientsHeaderKind:
                return collection.dequeueSupplementaryView(
                    IngredientsHeaderSupplementaryView.self,
                    withConfiguration: .init(),
                    ofKind: element,
                    for: indexPath
                )
            case Self.instructionsHeaderKind:
                return collectionView.dequeueSupplementaryView(
                    InstructionsHeaderSupplementaryView.self,
                    withConfiguration: .init(),
                    ofKind: element,
                    for: indexPath
                )
            default:
                return nil
            }
        }
        
        return dataSource
    }
}

// MARK: - UICollectionViewDelegate

extension MealDetailsViewController: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        reframeHeader()
        
        if
            collectionView.numberOfSections > 0 // avoid eager render on initial load
        {
            updateTitleDisplay()
        }
    }
}
