//
//  Regex.swift
//  HearsayMeals
//
//  Created by Mel Ludowise on 1/19/15.
//  Copyright (c) 2015 Mel Ludowise. All rights reserved.
//

import Foundation

class Regex {
    let internalExpression: NSRegularExpression
    let pattern: String

    init(_ pattern: String) {
        self.pattern = pattern
        var error: NSError?
        self.internalExpression = NSRegularExpression(pattern: pattern, options: .CaseInsensitive, error: &error)!
    }
    
    func test(input: String) -> Bool {
        let matches = self.internalExpression.matchesInString(input, options: nil, range:NSMakeRange(0, countElements(input)))
        return matches.count > 0
    }
    
    func replace(input: String, template: String) -> String {
        return internalExpression.stringByReplacingMatchesInString(input, options: nil, range:NSMakeRange(0, countElements(input)), withTemplate: template);
    }
}

extension String {
    func replace(pattern: String, template: String) -> String {
        return Regex(pattern).replace(self, template: template)
    }
}

infix operator =~ {}
func =~ (input: String, pattern: String) -> Bool {
    return Regex(pattern).test(input)
}
