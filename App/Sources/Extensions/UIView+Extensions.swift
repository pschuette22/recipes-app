//
//  UIView+Extensions.swift
//  Recipes
//
//  Created by Peter Schuette on 9/10/24.
//

import Foundation
import UIKit

extension UITraitCollection {
    var preferredShadowColor: UIColor {
        if userInterfaceStyle == .dark {
            UIColor.lightGray
        } else { // .light / .unspecified
            UIColor.darkGray
        }
    }
}
