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
    @discardableResult
    public static func execute(command: some Command) throws -> Data {
        let process = command.process
        do {
            try process.run()
            guard let pipe = process.standardOutput as? Pipe else {
                fatalError()
            }
            let fileHandle = pipe.fileHandleForReading
            return fileHandle.availableData
        } catch {
            throw error
        }
    }

    public static func execute(command: some Command, autoTrim: Bool = true) throws -> String {
        do {
            let data: Data = try Self.execute(command: command)
            guard let result = String(data: data, encoding: .utf8) else {
                throw ShellExecuteError.commandExecutedWithoutOutput
            }

            if autoTrim {
                return result.trimmed
            }

            return result
        } catch {
            throw error
        }
    }

    public static func execute<T: Decodable, D: TopLevelDecoder>(command: some Command, decoder: D) throws -> T where D.Input == Data {
        do {
            let data: Data = try Self.execute(command: command)
            return try decoder.decode(T.self, from: data)
        } catch {
            throw error
        }
    }

    @discardableResult
    public static func execute(commands: Array<some Command>) throws -> Data {
        guard !commands.isEmpty else {
            throw ShellExecuteError.emptyCommands
        }

        guard commands.count > 1 else {
            do {
                return try Self.execute(command: commands[0])
            } catch {
                throw error
            }
        }

        var inputPipe = commands.first?.process.standardOutput
        for command in commands[1...] {
            command.process.standardInput = inputPipe
            inputPipe = command.process.standardOutput
        }

        do {
            let lastIndex = commands.indices.index(before: commands.indices.endIndex)
            for command in commands[..<lastIndex] {
                try command.process.run()
            }
            return try Self.execute(command: commands[lastIndex])
        } catch {
            throw error
        }
    }

    public static func execute(commands: Array<some Command>, autoTrim: Bool = true) throws -> String {
        do {
            let data: Data = try Self.execute(commands: commands)
            guard let result = String(data: data, encoding: .utf8) else {
                throw ShellExecuteError.commandExecutedWithoutOutput
            }

            if autoTrim {
                return result.trimmed
            }

            return result
        } catch {
            throw error
        }
    }

    public static func execute<T: Decodable, D: TopLevelDecoder>(commands: Array<some Command>, decoder: D) throws -> T where D.Input == Data {
        do {
            let data: Data = try Self.execute(commands: commands)
            return try decoder.decode(T.self, from: data)
        } catch {
            throw error
        }
    }
}
