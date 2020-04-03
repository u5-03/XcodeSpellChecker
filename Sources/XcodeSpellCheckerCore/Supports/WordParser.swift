import Foundation

struct FileLoader {
    let url: URL

    func load() throws -> String {
        return try String(contentsOf: url)
    }
}

struct LineParser {
    let string: String
    let url: URL

    func parse() -> [WordEntity] {
        var result: [WordEntity] = []
        let lines = string.split(separator: "\n", omittingEmptySubsequences: false)
        lines.enumerated().forEach { offset, line in
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            if (trimmedLine.isEmpty || trimmedLine.hasPrefix("/*") || trimmedLine.hasSuffix("*/") || trimmedLine.hasPrefix("//")) { return }
            let wordFinder = WordFinder(sentence: String(line), url: url, line: offset)
            result.append(contentsOf: wordFinder.findWords())
        }
        return result
    }
}

struct WordFinder {
    let sentence: String
    let url: URL
    let line: Int

    func findWords() -> [WordEntity] {
        var result: [WordEntity] = []
        var word = ""
        sentence.enumerated().forEach({ arg in
            let (index, char) = arg
            if !char.isLetter { return }
            word.append(char)
            if shouldAppendWord(char: char, word: word, index: index), !word.isEmpty {
                result.append(WordEntity(url: url, line: line, position: index - (word.count - 1), word: word))
                word = ""
            }
        })
        return result
    }

     private func shouldAppendWord(char: Character, word: String, index: Int) -> Bool {
           if char.isUppercase, let nextLetter = shiftedChar(offset: 1, sentence: sentence, index: index, shouldFilterWithLetter: true), nextLetter.isUppercase, let twoIndexBehindChar = shiftedChar(offset: 2, sentence: sentence, index: index, shouldFilterWithLetter: true), twoIndexBehindChar.isLowercase {
               // case uppercase letters are consecutive(e.g. URL)
               return true
           } else if char.isLowercase, let nextLetter = shiftedChar(offset: 1, sentence: sentence, index: index, shouldFilterWithLetter: true), nextLetter.isUppercase {
               return true
           } else if let nextChar = shiftedChar(offset: 1, sentence: sentence, index: index), !nextChar.isLetter, shiftedChar(offset: 1, sentence: sentence, index: index, shouldFilterWithLetter: true) != nil {
               // case snake case
               return true
           }

           if sentence.count - 1 <= index, !word.isEmpty {
               return true
           } else if shiftedChar(offset: 1, sentence: sentence, index: index, shouldFilterWithLetter: true) == nil {
               return true
           }
           return false
       }

    private func shiftedChar(offset: Int, sentence: String, index: Int, shouldFilterWithLetter: Bool = false) -> Character? {
        if sentence.count > index + offset {
            if shouldFilterWithLetter, !sentence[sentence.index(sentence.startIndex, offsetBy: index + offset)].isLetter {
                return shiftedChar(offset: offset, sentence: sentence, index: index + 1, shouldFilterWithLetter: true)
            } else {
                return sentence[sentence.index(sentence.startIndex, offsetBy: index + offset)]
            }
        } else {
            return nil
        }
    }
}

public struct WordParser {
    public let url: URL
    public init(url: URL) {
        self.url = url
    }

    public func parse() throws -> [WordEntity] {
        let loader = FileLoader(url: url)
        let string = try loader.load()
        let parser = LineParser(string: string, url: url)
        return parser.parse()
    }
}
