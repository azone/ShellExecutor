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
    var environment: [String: String]? { get }

    var process: Process { get }
}

extension Command {
    public var executableURL: URL? {
        if let command = arguments.first, command.hasPrefix("/") {
            return URL(fileURLWithPath: command)
        }

        return URL(fileURLWithPath: "/usr/bin/env")
    }

    public var environment: [String: String]? { nil }

    public var process: Process {
        let process = Process()
        process.executableURL = executableURL
        process.currentDirectoryURL = currentDirectoryURL
        if executableURL?.path == arguments.first {
            process.arguments = Array(arguments.suffix(from: 1))
        } else {
            process.arguments = arguments
        }
        var environment: [String: String] = [:]
        if let env = ShellExecutor.globalEnvironment {
            environment.merge(env, uniquingKeysWith: { (_, v) in v })
        }
        if let env = self.environment {
            environment.merge(env, uniquingKeysWith: { (_, v) in v })
        }
        if !environment.isEmpty {
            environment.merge(ProcessInfo.processInfo.environment, uniquingKeysWith: { (v, _) in v })
            process.environment = environment
        }
        process.standardOutput = Pipe()
        process.standardError = Pipe()

        return process
    }
}

public struct GeneralCommand: Command, ExpressibleByArrayLiteral {
    public let arguments: [String]

    public var currentDirectoryURL: URL?

    public var environment: [String : String]?

    public typealias ArrayLiteralElement = String

    public init(arrayLiteral elements: String...) {
        arguments = elements
    }

    public init(_ arguments: String...) {
        self.arguments = arguments
    }

    public init(_ arguments: [String], environment: [String: String]? = nil) {
        self.arguments = arguments
        self.environment = environment
    }
}
