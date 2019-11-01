//
//  UIColorExtension.swift
//  SimpleList
//
//  Created by Jonah Pelfrey on 11/1/19.
//  Copyright © 2019 Jonah Pelfrey. All rights reserved.
//

import UIKit

extension UIColor {
    func toString() -> String {
        switch self {
        case .systemRed:
            return "System Red"
        case .systemOrange:
            return "System Orange"
        case .systemYellow:
            return "System Yellow"
        case .systemGreen:
            return "System Green"
        case .systemBlue:
            return "System Blue"
        case .systemPurple:
            return "System Purple"
        case .systemPink:
            return "System Pink"
        default:
            return ""
        }
    }
}
