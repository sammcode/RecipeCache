//
//  EncodableExt.swift
//  RecipeTimer
//
//  Created by Sam McGarry on 9/9/20.
//  Copyright © 2020 Sam McGarry. All rights reserved.
//

import Foundation

extension Encodable {
    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError()
        }
        return dictionary
    }
}
