# ShellExecutor

Util for executing shell commands, and getting the results easily(data, string, and any decodable).

## Requirements

- Xcode 14.0+
- Swift 5.7+
- macOS 10.15+

## Installation

You can install `ShellExecutor` via SPM(Swift Package Manager), adding `ShellExecutor` through Xcode, or as a dependency is as easy as adding it to the dependencies value of your `Package.swift`:

```
...
dependencies: [
    .package(url: "https://github.com/azone/ShellExecutor.git", from: "0.1.0")
]
...
```

## Usage

`ShellExecutor` provides many ways to execute shell commands.

### Using array as the command and arguments:

```swift
let command: GeneralCommand = ["ipconfig", "getifaddr", "en0"]
do {
    let ip: String = try ShellExecutor.execute(command: command)
    print(ip) // it will be printed like 192.168.1.174
} catch {
    print(error)
}
```

### Execute multiple commands like pipeline

```swift
let command1: GeneralCommand = ["echo", "Hello"]
let command2: GeneralCommand = ["cat"]
do {
    let result: String = try ShellExecutor.execute(commands: [command1, command2])
    print(result) // will be print Hello
} catch {
    print(error)
}
```

### Execute command with environment variables

```swift
let command = GeneralCommand(["/bin/bash", "-c", "echo $NAME"], environment: ["NAME": "Logan"])
do {
    let result: String = try ShellExecutor.execute(command: command)
    print(result) // will be print Logan
} catch {
    print(error)
}
```

### Execute shell command directly

```swift
do {
    let ip: String = ShellExecutor.execute(shell: "ipconfig getifaddr en0") // and you can also specify which shell you want to use
    print(ip) // it will be printed like 192.168.1.174
} catch {
    print(error)
}
```

### Other convenient ways to execute the commands

```swift
// decode struct from the command directly

struct Person: Decodable, Equatable {
    let name: String
    let age: Int
}

do {
    let jsonString = """
{ "name": "Logan", "age": 36 }
"""
    let command: GeneralCommand = ["echo", jsonString]
    let decoder = JSONDecoder()
    let person: Person = try ShellExecutor.execute(command: command, decoder: decoder)
    print(person) // Person(name: "Logan", age: 36)
} catch {
    print(error)
}

// execute shell command(s) using @resultBuilder
do {
    let ip: String = try ShellExecutor.execute {
        "ipconfig"
        "getifaddr"
        "en0"
    }
    print(ip) // 192.168.x.x
    
    let hello: String = try ShellExecutor.execute {
        ["echo", "Hello"]
        ["cat"]
    }
    print(hello) // Hello
} catch {
    print(error)
}
```

**For more information & examples please see the tests.**

## LICENSE

---

`ShellExecutor` is released under the MIT license. See [LICENSE](https://github.com/azone/ShellExecutor/blob/master/LICENSE) for details.
