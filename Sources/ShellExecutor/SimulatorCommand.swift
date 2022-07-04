//
//  SimulatorCommand.swift
//  
//
//  Created by 王要正 on 2022/7/4.
//

import Foundation

struct SimulatorCommand: ShellCommand {
    var arguments: [String]

    var currentDirectoryURL: URL?

    typealias ArrayLiteralElement = String

    init(arrayLiteral elements: String...) {
        arguments = ["xcrun", "simctl"] + elements
    }
}
