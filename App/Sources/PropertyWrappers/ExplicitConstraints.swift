//
//  ExplicitConstraints.swift
//  Recipes
//
//  Created by Peter Schuette on 9/7/24.
//

import Foundation
import UIKit

@propertyWrapper struct ExplicitConstraints<SomeView: UIView> {
    var wrappedValue: SomeView

    init(wrappedValue: SomeView) {
        self.wrappedValue = wrappedValue
        wrappedValue.translatesAutoresizingMaskIntoConstraints = false
    }
}
