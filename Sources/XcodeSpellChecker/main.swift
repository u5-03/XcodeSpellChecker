import XcodeSpellCheckerCore
import Foundation
import Yams
import Cocoa
import Commander

final class XcodeSpellChecker {
    func run(filePaths: String, ymlPath: String, language: String) {
        let XcodeSpellChecker = NSSpellChecker.shared
        var whiteWordList: [String] = []
        var includePath: [String] = []
        var excludePath: [String] = []
        if filePaths.isEmpty {
            print("File paths to be checked with spelling of words are not set")
            return
        }
        if !ymlPath.isEmpty {
            let url = URL(fileURLWithPath: ymlPath)
            guard let optionsParameters: YmlEntity = parseYaml(for: url) else {
                print("Fail to parse yaml options.")
                return
            }
            if let whiteList = optionsParameters.whiteList, !whiteList.isEmpty {
                whiteWordList = whiteList
            }
            if let optionExcludePath = optionsParameters.excludePath {
                excludePath = optionExcludePath
            }
            if let optionIncludePath = optionsParameters.includePath {
                includePath = optionIncludePath
            }
        }
        XcodeSpellChecker.setIgnoredWords(whiteWordList + DefaultWhiteList.list, inSpellDocumentWithTag: 0)
        let files = Commands.filePathArray(filePaths: filePaths, includePath: includePath, excludePath: excludePath)
        if !XcodeSpellChecker.setLanguage(language) {
            print("Language:\(language) is not supported.")
            return
        }

        let fileNameArray = FileNameFinder().findFileName(fileArray: files)
        fileNameArray.forEach({
            let range = XcodeSpellChecker.checkSpelling(of: $0, startingAt: 0)
            if range.location > $0.count { return }
            if let suggestion = XcodeSpellChecker.correction(forWordRange: range, in: $0, language: language, inSpellDocumentWithTag: 0) {
                print("warning: Is FileName `\($0)` typo of `\(suggestion)` (XcodeSpellChecker)")
            } else {
                print("warning: Is FileName `\($0)` typo? (XcodeSpellChecker)")
            }
        })
        let warnings: [WordEntity] = files.map({ file -> [WordEntity] in
            let url = URL(fileURLWithPath: file)
            let wordParser = WordParser(url: url)
            guard let words = try? wordParser.parse() else { return [] }
            return words.map({
                var word = $0
                let range = XcodeSpellChecker.checkSpelling(of: word.value, startingAt: 0)
                if range.location > word.value.count { return nil }
                if let suggestion = XcodeSpellChecker.correction(forWordRange: range, in: word.value, language: language, inSpellDocumentWithTag: 0) {
                    word.suggestion = suggestion
                }
                return word
            })
            .compactMap({ $0 })
        })
        .flatMap({ $0 })

        if warnings.isEmpty {
            print("The spell of all words is correct!")
            return
        }

        warnings.forEach { word in
            if let suggestion = word.suggestion {
                print("\(word.url.path):\(word.line + 1):\(word.position + 1): warning: Maybe `\(word.value)` is typo of `\(suggestion)`. (XcodeSpellChecker)")
            } else {
                print("\(word.url.path):\(word.line + 1):\(word.position + 1): warning: Is `\(word.value)` typo? (XcodeSpellChecker)")
            }
        }
    }

    private func parseYaml<T>(for url: URL) -> T? where T: Decodable {
        let decoder = YAMLDecoder()
        guard let ymlString = try? String(contentsOf: url) else { return nil }
        return try? decoder.decode(from: ymlString)
    }
}
let main = command(
    Option("files", default: "", description: "File paths to be checked with spelling of words"),
    Option("yml", default: "", description: "File path to write options"),
    Option("language", default: "en", flag: "l")
    ) { files, yml, language in
        let spellChecker = XcodeSpellChecker()
        spellChecker.run(filePaths: files, ymlPath: yml, language: language)
}
main.run()
