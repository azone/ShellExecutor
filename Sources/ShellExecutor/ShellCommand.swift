//
//  ShellCommand.swift
//  
//
//  Created by 王要正 on 2022/7/6.
//

import Foundation

public enum ShellType: String {
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
        self = Self.init(value)
    }

    public init(_ command: String, shellType: ShellType = .default) {
        if shellType == .default {
            if let shell = ProcessInfo.processInfo.environment["SHELL"] {
                executableURL = URL(fileURLWithPath: shell)
                arguments = ["-c", command]
            } else {
                executableURL = Self.envURL
                arguments = ["bash", "-c", command]
            }
        } else {
            executableURL = Self.envURL
            arguments = [shellType.rawValue, "-c", command]
        }
    }

    public static func bash(_ command: String) -> Self {
        .init(command, shellType: .bash)
    }

    public static func csh(_ command: String) -> Self {
        .init(command, shellType: .csh)
    }

    public static func ksh(_ command: String) -> Self {
        .init(command, shellType: .ksh)
    }

    public static func sh(_ command: String) -> Self {
        .init(command, shellType: .sh)
    }

    public static func tcsh(_ command: String) -> Self {
        .init(command, shellType: .tcsh)
    }

    public static func zsh(_ command: String) -> Self {
        .init(command, shellType: .zsh)
    }

    public static func fish(_ command: String) -> Self {
        .init(command, shellType: .fish)
    }
}
