//
//  Command.swift
//  
//
//  Created by 王要正 on 2022/7/4.
//

import Foundation

public protocol Command {
    var executableURL: URL? { get }
    var arguments: [String] { get }
    var currentDirectoryURL: URL? { get }

    var process: Process { get }
}

extension Command {
    public var executableURL: URL? {
        if arguments.first?.hasPrefix("/") == true {
            return nil
        }

        return URL(fileURLWithPath: "/usr/bin/env")
    }
}

public struct GeneralCommand: Command, ExpressibleByArrayLiteral {
    public let arguments: [String]

    public var currentDirectoryURL: URL?

    public let process: Process

    public typealias ArrayLiteralElement = String

    public init(arrayLiteral elements: String...) {
        arguments = elements

        process = Process()
        process.executableURL = executableURL
        process.currentDirectoryURL = currentDirectoryURL
        process.arguments = arguments
        process.standardOutput = Pipe()
        process.standardError = Pipe()
    }
}
