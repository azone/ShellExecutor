import Foundation
import Combine

public struct ShellExecutor {
    public private(set) var text = "Hello, World!"

    private init() {}
}

enum ShellExecuteError: Error {
    case commandExecutedWithoutOutput
    case emptyCommands
}

extension ShellExecutor {
    private static func execute(process: Process) throws -> Data {
        do {
            try process.run()
            guard let pipe = process.standardOutput as? Pipe else {
                fatalError()
            }
            let fileHandle = pipe.fileHandleForReading
            if #available(macOS 10.15.4, *) {
                if let data = try fileHandle.readToEnd() {
                    return data
                }
                let executePath = process.executableURL?.path
                let errorMessage = "No output for: \(executePath ?? ""), arguments: \(process.arguments ?? [])"
                if let errorData = errorMessage.data(using: .utf8) {
                    FileHandle.standardError.write(errorData)
                }
                return Data()
            } else {
                return fileHandle.readDataToEndOfFile()
            }
        } catch {
            throw error
        }
    }

    @discardableResult
    public static func execute(command: some Command) throws -> Data {
        let process = command.process
        return try Self.execute(process: process)
    }

    public static func execute(command: some Command, autoTrim: Bool = true) throws -> String {
        let data: Data = try Self.execute(command: command)
        guard let result = String(data: data, encoding: .utf8) else {
            throw ShellExecuteError.commandExecutedWithoutOutput
        }

        if autoTrim {
            return result.trimmed
        }

        return result
    }

    public static func execute<T: Decodable, D: TopLevelDecoder>(command: some Command, decoder: D) throws -> T where D.Input == Data {
        let data: Data = try Self.execute(command: command)
        return try decoder.decode(T.self, from: data)
    }

    @discardableResult
    public static func execute(commands: Array<some Command>) throws -> Data {
        guard !commands.isEmpty else {
            throw ShellExecuteError.emptyCommands
        }

        guard commands.count > 1 else {
            return try Self.execute(command: commands[0])
        }

        let processes = commands.map(\.process)
        var inputPipe = processes.first?.standardOutput
        for process in processes[1...] {
            process.standardInput = inputPipe
            inputPipe = process.standardOutput
        }

        let lastIndex = processes.indices.index(before: commands.indices.endIndex)
        for process in processes[..<lastIndex] {
            try process.run()
        }

        return try Self.execute(process: processes[lastIndex])
    }

    public static func execute(commands: Array<some Command>, autoTrim: Bool = true) throws -> String {
        let data: Data = try Self.execute(commands: commands)
        guard let result = String(data: data, encoding: .utf8) else {
            throw ShellExecuteError.commandExecutedWithoutOutput
        }

        if autoTrim {
            return result.trimmed
        }

        return result
    }

    public static func execute<T: Decodable, D: TopLevelDecoder>(commands: Array<some Command>, decoder: D) throws -> T where D.Input == Data {
        let data: Data = try Self.execute(commands: commands)
        return try decoder.decode(T.self, from: data)
    }

    public static func execute(shell: String, shellType type: ShellType = .default) throws -> Data {
        let command: ShellCommand = .init(shell, shellType: type)
        return try Self.execute(command: command)
    }

    public static func execute(shell: String, shellType type: ShellType = .default, autoTrim: Bool = true) throws -> String {
        let data = try Self.execute(shell: shell, shellType: type)
        guard let result = String(data: data, encoding: .utf8) else {
            throw ShellExecuteError.commandExecutedWithoutOutput
        }

        if autoTrim {
            return result.trimmed
        }

        return result
    }

    public static func execute<T: Decodable, D: TopLevelDecoder>(
        shell: String,
        shellType type: ShellType = .default,
        decoder: D
    ) throws -> T where D.Input == Data {
        let data = try Self.execute(shell: shell, shellType: type)
        return try decoder.decode(T.self, from: data)
    }
}
