import XCTest
@testable import ShellExecutor

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
        } catch {
            XCTFail("\(#function) with throwed error: \(error)")
        }
    }

    func testShellCommand() {
        let command = """
echo "Hello" | cat
"""
        do {
            for type in ShellType.allCases  {
                let result: String = try ShellExecutor.execute(shell: command, shellType: type)
                XCTAssertEqual(result, "Hello", "\(type): \(command)")
            }
        } catch {
            XCTFail("\(#function) with throwed error: \(error)")
        }
    }
}
