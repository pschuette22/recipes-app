// 
//  MealDetailsViewModel.swift
//  Recipes
//
//  Created by Peter Schuette on 9/9/24.
//

import AsyncState
import Foundation

final class MealDetailsViewModel: ViewModeling {
    // -- State Definition --
    typealias State = MealDetailsState
    typealias Sections = State.Sections
    typealias Items = State.Items

    private(set) var state: State {
        didSet {
            openStateStream.send(state)
        }
    }

    // -- State Streaming --
    private var openStateStream = OpenAsyncBroadcast<State>()
    var stateStream: any AsyncBroadcast<State> {
        openStateStream
    }
    
    convenience init(summary: MealSummaryModel) {
        self.init(
            MealDetailsState(
                photoURL: summary.image,
                title: summary.title
            )
        )
    }
    
    required init(_ initialState: State) {
        state = initialState
    }
}

// MARK: - ViewModeling

extension MealDetailsViewModel {
    @MainActor
    func currentState() -> State {
        state
    }
}
