import Foundation

extension Substring {
    var isLowerCase: Bool {
        let characterSet = CharacterSet.lowercaseLetters
        return rangeOfCharacter(from: characterSet) != nil
    }

    var isUpperCase: Bool {
        let characterSet = CharacterSet.uppercaseLetters
        return rangeOfCharacter(from: characterSet) != nil
    }
}
