import Foundation

public enum CheckType {
    case fileName(file: FileNameEntity)
    case word(word: WordEntity)
}

public struct FileNameEntity: Equatable {
    public let fileName: String
    public var suggestion: String?

    public init(fileName: String, suggestion: String?) {
        self.fileName = fileName
        self.suggestion = suggestion
    }
}

public struct WordEntity: Equatable {
    public let url: URL
    public let line: Int
    public let position: Int
    public let value: String
    public var suggestion: String?
}

