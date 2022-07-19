import XCTest
@testable import ShellExecutor

struct Person: Decodable, Equatable {
    let name: String
    let age: Int
}

extension ShellType: CaseIterable {
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

final class ShellExecutorTests: XCTestCase {
    func testWhichCommand() {
        do {
            let command: GeneralCommand = ["which", "which"]
            let dataResult: Data = try ShellExecutor.execute(command: command)
            XCTAssertEqual(dataResult, "/usr/bin/which\n".data(using: .utf8))

            let stringResult: String = try ShellExecutor.execute(command: command)
            XCTAssertEqual(stringResult, "/usr/bin/which")
        } catch {
            XCTFail("\(#function) with throwed error: \(error)")
        }
    }

    func testPipeCommands() {
        do {
            let command1: GeneralCommand = ["echo", "Hello"]
            let command2: GeneralCommand = ["cat"]

            let stringResult: String = try ShellExecutor.execute(commands: [command1, command2])
            XCTAssertEqual(stringResult, "Hello", "echo Hello | cat")

            let resultForBuilder: String = try ShellExecutor.execute {
                ["echo", "Hello"]
                ["cat"]
            }
            XCTAssertEqual(resultForBuilder, "Hello", "Test ShellExecutor Builder")
        } catch {
            XCTFail("\(#function) with throwed error: \(error)")
        }
    }

    func testShellCommand() {
        let command = """
echo "Hello" | cat
"""
        do {
            // FIXME: execute error when specified fish shell and test in Xcode(env: fish: No such file or directory)
            for type in ShellType.allCases where type != .fish {
                let result: String = try ShellExecutor.execute(shell: command, shellType: type)
                XCTAssertEqual(result, "Hello", "\(type): \(command)")
            }
        } catch {
            XCTFail("\(#function) with throwed error: \(error)")
        }
    }

    func testDecodable() {
        let jsonString = """
{ "name": "Logan", "age": 36 }
"""
        let command: GeneralCommand = ["echo", jsonString]
        do {
            let decoder = JSONDecoder()
            let personForTest = Person(name: "Logan", age: 36)
            var person: Person = try ShellExecutor.execute(command: command, decoder: decoder)
            XCTAssertEqual(person, personForTest, "Test normal command")

            person = try ShellExecutor.execute(commands: [command, GeneralCommand("cat")], decoder: decoder)
            XCTAssertEqual(person, personForTest, "Test pipeline")


            // FIXME: execute error when specified fish shell and test in Xcode(env: fish: No such file or directory)
            for type in ShellType.allCases where type != .fish {
                person = try ShellExecutor.execute(
                    shell: "echo '\(jsonString)'",
                    shellType: type,
                    decoder: decoder
                )
                XCTAssertEqual(person, personForTest, "Test shell \(type): \(command)")
            }
        } catch {
            XCTFail("\(#function) with throwed error: \(error)")
        }
    }
}
