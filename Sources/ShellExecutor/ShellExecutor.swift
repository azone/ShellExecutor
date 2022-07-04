public struct ShellExecutor {
    public private(set) var text = "Hello, World!"

    private init() {}
}

extension ShellCommand {
    public static func execute<T: Decodable>(command: some ShellCommand) throws -> T {

    }

    public static func execute<T: Decodable>(commands: Array<some ShellCommand>) throws -> T {
    }
}
