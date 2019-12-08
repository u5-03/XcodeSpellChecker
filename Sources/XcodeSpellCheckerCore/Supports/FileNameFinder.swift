import Foundation

public struct FileNameFinder {

    public init() {}

    public func findFileName(fileArray: [String]) -> [String] {
        return fileArray
            .map({
                let fileURL = URL(fileURLWithPath: $0)
                if !fileURL.pathExtension.isEmpty,
                    let range = fileURL.lastPathComponent.range(of: ".\(fileURL.pathExtension)") {
                    return fileURL.lastPathComponent.replacingCharacters(in: range, with: "")
                } else {
                    return fileURL.lastPathComponent
                }
            })
    }
}
