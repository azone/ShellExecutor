//
//  ShellExecutorTests.swift
//  ShellExecutor
//
//  Created by Logan Wang on 2024/11/1.
//

import Testing
import Foundation

@testable import ShellExecutor

struct Person: Decodable, Equatable {
    let name: String
    let age: Int
}

extension ShellType: @retroactive CaseIterable {
    public static var allCases: [ShellType] {
        return [
            .default,
            .bash,
            .csh,
            .ksh,
            .sh,
            .tcsh,
            .zsh,
            .fish,
        ]
    }
}


struct ShellExecutorTest {

    @Test("Test switch command")
    func switchCommand() throws {
        let command: GeneralCommand = ["which", "which"]
        let dataResult: Data = try ShellExecutor.execute(command: command)
        #expect(dataResult == "/usr/bin/which\n".data(using: .utf8))

        let stringResult: String = try ShellExecutor.execute(command: command)
        #expect(stringResult == "/usr/bin/which")
    }

    @Test("Test pipe commands")
    func pipeCommands() throws {
        let command1: GeneralCommand = ["echo", "Hello"]
        let command2: GeneralCommand = ["cat"]

        let stringResult: String = try ShellExecutor.execute(commands: [command1, command2])
        #expect(stringResult == "Hello", "echo Hello | cat")

        let resultForBuilder: String = try ShellExecutor.execute {
            ["echo", "Hello"]
            ["cat"]
        }
        #expect(resultForBuilder == "Hello", "Test ShellExecutor Builder")

        let resultForBuilder2: String = try ShellExecutor.execute {
            "echo"
            "Hello"
        }
        #expect(resultForBuilder2 == "Hello", "Test ShellExecutor Builder for single command")
    }

    @Test("Test shell command", arguments: ShellType.allCases)
    func shellCommand(shellType: ShellType) throws {
        let command = """
echo "Hello" | cat
"""
        try withKnownIssue(isIntermittent: true) {
            let result: String = try ShellExecutor.execute(shell: command, shellType: shellType)
            #expect(result == "Hello", "\(shellType): \(command)")
        } when: {
            shellType == .fish
        } matching: { issue in
            // .executeFailed(code: 127, message: "env: fish: No such file or directory")
            if let error = issue.error as? ShellExecuteError,
               case .executeFailed(let code, _) = error, code == 127 {
                return true
            }
            return false
        }
    }

    @Test("Decodable")
    func decodable() throws {
        let jsonString = """
{ "name": "Logan", "age": 38 }
"""
        let command: GeneralCommand = ["echo", jsonString]
        let decoder = JSONDecoder()
        let personForTest = Person(name: "Logan", age: 38)
        var person: Person = try ShellExecutor.execute(command: command, decoder: decoder)
        #expect(person == personForTest, "Test normal command")

        person = try ShellExecutor.execute(commands: [command, GeneralCommand("cat")], decoder: decoder)
        #expect(person == personForTest, "Test pipeline")
    }

    @Test("Decodable with different shells", arguments: ShellType.allCases)
    func decodable(shellType: ShellType) throws {
        let jsonString = """
{ "name": "Logan", "age": 38 }
"""
        let command: GeneralCommand = ["echo", jsonString]
        let decoder = JSONDecoder()
        let personForTest = Person(name: "Logan", age: 38)
        try withKnownIssue(isIntermittent: true) {
            let person: Person = try ShellExecutor.execute(
                shell: "echo '\(jsonString)'",
                shellType: shellType,
                decoder: decoder
            )
            #expect(person == personForTest, "Test shell \(shellType): \(command)")
        } when: {
            shellType == .fish
        } matching: { issue in
            // .executeFailed(code: 127, message: "env: fish: No such file or directory")
            if let error = issue.error as? ShellExecuteError,
               case .executeFailed(let code, _) = error,
               code == 127 {
                return true
            }

            return false
        }
    }

    @Test("Test envinroment")
    func environment() async throws {
        let command = GeneralCommand(["/bin/bash", "-c", "echo $NAME"], environment: ["NAME": "Logan"])
        let result: String = try ShellExecutor.execute(command: command)
        #expect(result == "Logan", "Test GeneralCommand with environment variables")
    }
}
