import Foundation

public struct YmlEntity: Decodable {
    public var whiteList: [String]?
    public var includePath: [String]?
    public var excludePath: [String]?
}
