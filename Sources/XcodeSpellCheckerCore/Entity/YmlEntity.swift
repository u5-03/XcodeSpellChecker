import Foundation

public struct YmlEntity: Decodable {
    public var allowList: [String]?
    public var includePath: [String]?
    public var excludePath: [String]?
}
