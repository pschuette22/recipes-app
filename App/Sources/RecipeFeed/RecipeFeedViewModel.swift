// 
//  RecipeFeedViewModel.swift
//  Recipes
//
//  Created by Peter Schuette on 9/3/24.
//

import AsyncState
import Foundation

final class RecipeFeedViewModel: ViewModeling {
    // -- State Definition --
    typealias State = RecipeFeedState
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

    required init(_ initialState: State = .init()) {
        state = initialState
    }
}

// MARK: - ViewModeling

extension RecipeFeedViewModel {
    @MainActor
    func currentState() -> State {
        state
    }
}
