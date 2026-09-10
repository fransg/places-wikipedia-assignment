//
//  String+Formatter.swift
//  Places
//
//  Created by Frans Glorie on 10/09/2026.
//

import Foundation

extension String {
    var trimmed: Self {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
