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
            print("XcodeSpellChecker: File paths to be checked with spelling of words are not set")
            return
        }
        if !ymlPath.isEmpty {
            let url = URL(fileURLWithPath: ymlPath)
            guard let optionsParameters: YmlEntity = parseYaml(for: url) else {
                print("XcodeSpellChecker: ⚠️Fail to parse yaml options. Check 'Xcode-spellChecker.yml' file in your project.")
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
            print("XcodeSpellChecker: Language:\(language) is not supported.")
            return
        }
        let checkTargetList: [CheckType] = FileNameFinder().findFileName(fileArray: files)
            .map({ .fileName(file: FileNameEntity(fileName: $0, suggestion: nil))  })
            + files.map({ file -> [WordEntity]? in
                let url = URL(fileURLWithPath: file)
                let wordParser = WordParser(url: url)
                return try? wordParser.parse()
            })
            .compactMap({ $0 })
            .flatMap({ $0 })
            .map({ .word(word: $0) })

        if checkTargetList.isEmpty {
            print("XcodeSpellChecker: The spell of all words/fileName is correct!")
            return
        }

        var wordSearchTypeList: [String: WordSearchEntity] = [:]
        var fileNameSearchTypeList: [String: FileNameSearchEntity] = [:]
        checkTargetList.forEach({
            switch $0 {
            case .word(let wordEntity):
                if wordSearchTypeList[wordEntity.word] == nil {
                    let wordSearchInfo = WordSearchInfoEntity(url: wordEntity.url, line: wordEntity.line, position: wordEntity.position)
                    wordSearchTypeList[wordEntity.word] = WordSearchEntity(wordSearchInfoList: [wordSearchInfo], word: wordEntity.word)
                } else {
                    let wordSearchInfo = WordSearchInfoEntity(url: wordEntity.url, line: wordEntity.line, position: wordEntity.position)
                    wordSearchTypeList[wordEntity.word]?.wordSearchInfoList.append(wordSearchInfo)
                }
            case .fileName(let file):
                if fileNameSearchTypeList[file.fileName] == nil {
                    let fileNameSearchType = FileNameSearchEntity(fileName: file.fileName)
                    fileNameSearchTypeList[file.fileName] = fileNameSearchType
                }
            }
        })
        var warningCount = 0
        wordSearchTypeList.forEach { (key, value) in
            let range = XcodeSpellChecker.checkSpelling(of: value.word, startingAt: 0)
            if range.location > value.word.count { return }
            let suggestion = XcodeSpellChecker.correction(forWordRange: range, in: value.word, language: language, inSpellDocumentWithTag: 0)
            value.wordSearchInfoList.forEach({
                if let suggestionParsed = suggestion {
                    print("\($0.url.path):\($0.line + 1):\($0.position + 1): warning: Maybe `\(value.word)` is typo of `\(suggestionParsed)`. (XcodeSpellChecker)")
                } else {
                    print("\($0.url.path):\($0.line + 1):\($0.position + 1): warning: Is `\(value.word)` typo? (XcodeSpellChecker)")
                }
                warningCount+=1
            })
        }
        fileNameSearchTypeList.forEach({ (key, value) in
            let range = XcodeSpellChecker.checkSpelling(of: value.fileName, startingAt: 0)
            if range.location > value.fileName.count { return }
            let suggestion = XcodeSpellChecker.correction(forWordRange: range, in: value.fileName, language: language, inSpellDocumentWithTag: 0)
            if let suggestionParsed = suggestion {
                print("warning: Is FileName `\(value.fileName)` typo of `\(suggestionParsed)`? (XcodeSpellChecker)")
            } else {
                print("warning: Is FileName `\(value.fileName)` typo? (XcodeSpellChecker)")
            }
            warningCount+=1
        })
        print("Complete spell checking(Warning count is \(warningCount)). (XcodeSpellChecker)")
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
