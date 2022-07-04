//
//  ShellCommand.swift
//  
//
//  Created by 王要正 on 2022/7/4.
//

import Foundation

protocol ShellCommand: ExpressibleByArrayLiteral {
    var executableURL: URL? { get }
    var arguments: [String] { get }
    var currentDirectoryURL: URL? { get }

    var process: Process { get }
}

extension ShellCommand {
    var executableURL: URL? { URL(fileURLWithPath: "/usr/bin/env") }

    var process: Process {
        let process = Process()
        process.executableURL = executableURL
        process.currentDirectoryURL = currentDirectoryURL
        process.arguments = arguments
        process.standardInput = Pipe()
        process.standardOutput = Pipe()
        process.standardError = Pipe()
        return process
    }
}

struct GeneralShellCommand: ShellCommand {
    var arguments: [String]

    var currentDirectoryURL: URL?

    typealias ArrayLiteralElement = String

    init(arrayLiteral elements: String...) {
        arguments = elements
    }
}
