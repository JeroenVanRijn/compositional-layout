//
//  Label.swift
//  CollectionTest
//
//  Created by Jeroen van Rijn on 27/10/2023.
//

import Foundation

struct Label: Identifiable, Hashable {
    let id = UUID()
    let text: String
}
