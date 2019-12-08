import Foundation

public struct Commands {
    static var arguments: [String] = CommandLine.arguments
    static var optionPrefix: String = "-"
    static var filePathsPrefix: String = "--"

    public static func has(_ option: String) -> Bool {
        let rawValue = optionPrefix + option
        return arguments.contains(rawValue)
    }

    public static func value(of option: String) -> String? {
        let rawValue = optionPrefix + option
        guard let index = arguments.firstIndex(of: rawValue) else { return nil }
        let nextIndex = arguments.index(index, offsetBy: 1)
        return arguments.count > nextIndex ? arguments[nextIndex] : nil
    }

    public static func filePathArray(filePaths: String, includePath: [String] = [], excludePath: [String] = []) -> [String] {
        let files = filePaths.split(separator: ":").map(String.init)
        return files.lazy.enumerated()
            .map({ $0.element })
            .filter({ filePath in
                if includePath.isEmpty {
                    return true
                } else {
                    return includePath.map({
                        filePath.contains($0)
                    })
                    .contains(true)
                }
            })
            .filter({ filePath in
                if excludePath.isEmpty {
                    return true
                } else {
                    return excludePath.map({
                        !filePath.contains($0)
                    })
                    .allSatisfy({ $0 })
                }
            })
    }
}
