import Foundation

public enum CheckType {
    case fileName(file: FileNameEntity)
    case word(word: WordEntity)
}

public enum SearchType {
    case fileName(file: FileNameEntity)
    case word(word: WordEntity)
    case wordDuplicate(word: WordEntity)
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
    public let word: String
    public var suggestion: String?
}

public struct FileNameSearchEntity: Equatable {
    public let fileName: String
    
    public init(fileName: String) {
        self.fileName = fileName
    }
}

public struct WordSearchEntity: Equatable {
    public var wordSearchInfoList: [WordSearchInfoEntity]
    public let word: String
    
    public init(wordSearchInfoList: [WordSearchInfoEntity], word: String) {
        self.wordSearchInfoList = wordSearchInfoList
        self.word = word
    }
}

public struct WordSearchInfoEntity: Equatable {
    public let url: URL
    public let line: Int
    public let position: Int

    public init(url: URL, line: Int, position: Int) {
        self.url = url
        self.line = line
        self.position = position
    }
}

