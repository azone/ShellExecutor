//
//  ShellCommand.swift
//  
//
//  Created by 王要正 on 2022/7/6.
//

import Foundation

public enum ShellType: CaseIterable {
    case `default`
    case bash
    case csh
    case ksh
    case sh
    case tcsh
    case zsh
    case fish
}

public struct ShellCommand: Command, ExpressibleByStringLiteral {
    public typealias StringLiteralType = String

    public private(set) var executableURL: URL?
    public private(set) var arguments: [String] = []
    public var currentDirectoryURL: URL?

    private static let envURL = URL(fileURLWithPath: "/usr/bin/env")

    private init() {}

    public init(stringLiteral value: String) {
        if let shell = ProcessInfo.processInfo.environment["SHELL"] {
            executableURL = URL(fileURLWithPath: shell)
            arguments = ["-c", value]
        } else {
            executableURL = Self.envURL
            arguments = ["bash", "-c", value]
        }
    }

    public init(_ command: String) {
        self = Self.init(stringLiteral: command)
    }

    public static func bash(_ command: String) -> Self {
        var shellCommand = ShellCommand()
        shellCommand.executableURL = Self.envURL
        shellCommand.arguments = ["bash", "-c", command]
        return shellCommand
    }

    public static func csh(_ command: String) -> Self {
        var shellCommand = ShellCommand()
        shellCommand.executableURL = Self.envURL
        shellCommand.arguments = ["csh", "-c", command]
        return shellCommand
    }

    public static func ksh(_ command: String) -> Self {
        var shellCommand = ShellCommand()
        shellCommand.executableURL = Self.envURL
        shellCommand.arguments = ["ksh", "-c", command]
        return shellCommand
    }

    public static func sh(_ command: String) -> Self {
        var shellCommand = ShellCommand()
        shellCommand.executableURL = Self.envURL
        shellCommand.arguments = ["sh", "-c", command]
        return shellCommand
    }

    public static func tcsh(_ command: String) -> Self {
        var shellCommand = ShellCommand()
        shellCommand.executableURL = Self.envURL
        shellCommand.arguments = ["tcsh", "-c", command]
        return shellCommand
    }

    public static func zsh(_ command: String) -> Self {
        var shellCommand = ShellCommand()
        shellCommand.executableURL = Self.envURL
        shellCommand.arguments = ["zsh", "-c", command]
        return shellCommand
    }

    public static func fish(_ command: String) -> Self {
        var shellCommand = ShellCommand()
        shellCommand.executableURL = Self.envURL
        shellCommand.arguments = ["fish", "-c", command]
        return shellCommand
    }
}
