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

        var checkTargetDic: [String: CheckType] = [:]
        checkTargetList.forEach({
            switch $0 {
            case .word(let word):
                if checkTargetDic[word.value] == nil {
                    checkTargetDic[word.value] = .word(word: word)
                }
            case .fileName(let file):
                if checkTargetDic[file.fileName] == nil {
                    checkTargetDic[file.fileName] = .fileName(file: file)
                }
            }
        })
        let filteredCheckList = checkTargetDic.map({ $0.value })
            .map({ checkType -> CheckType? in
                switch checkType {
                case.word(let word):
                    var checkedWord = word
                    let range = XcodeSpellChecker.checkSpelling(of: checkedWord.value, startingAt: 0)
                    if range.location > checkedWord.value.count { return nil }
                    if let suggestion = XcodeSpellChecker.correction(forWordRange: range, in: checkedWord.value, language: language, inSpellDocumentWithTag: 0) {
                        checkedWord.suggestion = suggestion
                    }
                    return .word(word: checkedWord)
                case .fileName(let file):
                    var checkedFileName = file
                    let range = XcodeSpellChecker.checkSpelling(of: checkedFileName.fileName, startingAt: 0)
                    if range.location > checkedFileName.fileName.count { return nil }
                    if let suggestion = XcodeSpellChecker.correction(forWordRange: range, in: checkedFileName.fileName, language: language, inSpellDocumentWithTag: 0) {
                        checkedFileName.suggestion = suggestion
                    }
                    return .fileName(file: checkedFileName)
                }
            })
            .compactMap({ $0 })
        filteredCheckList.forEach { checkType in
            switch checkType {
            case .word(let word):
                if let suggestion = word.suggestion {
                    print("\(word.url.path):\(word.line + 1):\(word.position + 1): warning: Maybe `\(word.value)` is typo of `\(suggestion)`. (XcodeSpellChecker)")
                } else {
                    print("\(word.url.path):\(word.line + 1):\(word.position + 1): warning: Is `\(word.value)` typo? (XcodeSpellChecker)")
                }
            case .fileName(let file):
                if let suggestion = file.suggestion {
                    print("warning: Is FileName `\(file.fileName)` typo of `\(suggestion)`? (XcodeSpellChecker)")
                } else {
                    print("warning: Is FileName `\(file.fileName)` typo? (XcodeSpellChecker)")
                }
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
